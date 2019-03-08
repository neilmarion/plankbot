# 1. Total number of PRs and number of approved
# 2. Requestor with the most PR requests
# 3. Reviewer with the most approvals
# 4. Fastest reviewer
# 5. PR reviewed the fastest
# 6. PR reviewed the slowest

module Plankbot
  class BuildDailyStats
    def self.execute
      stats = [
        build_pull_request_count,
        build_most_requests,
        build_most_approvals,
        build_fastest_approver,
        build_approval_speed,
      ].compact

      return if stats.blank?

      message = "*These are the stats for the day - #{DateTime.current.strftime("%B %d, %Y")}:*\n\n" +
        stats.each_with_index.map do |x,i|
          "#{i+1}. #{x}"
        end.join("\n")

      message
    end

    private

    def self.build_pull_request_count
      prs = PullRequest.
        where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
      pr_count = prs.count

      thumbed = PullRequestReviewerRelationship.
        where(approved_at: Time.current.beginning_of_day..Time.current.end_of_day).map{ |x| x.pull_request }.uniq

      approved_count = thumbed.select{ |x| x.approved? }.count

      return if pr_count == 0 && approved_count == 0

      "#{pr_count} PRs were sent for review, #{approved_count} were approved :muscle:"
    end

    def self.build_most_requests
      counts = Reviewer.all.map do |x|
        {
          name: x.name,
          slack_id: x.slack_id,
          count: x.requested_pull_requests.
            where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count
        }
      end

      max = counts.sort_by{|x| x[:count] }.last

      return if max[:count] == 0

      y = counts.select {|x| x[:count] == max[:count] }

      names = y.map{|x| "<@#{x[:slack_id]}>"}.join(", ")

      "#{names} has the most review requests with #{max[:count]} PRs :raised_hands:"
    end

    def self.build_most_approvals
      counts = Reviewer.all.map do |x|
        {
          slack_id: x.slack_id,
          name: x.name,
          count: x.pull_request_reviewer_relationships.
            where(approved_at: Time.current.beginning_of_day..Time.current.end_of_day).count
        }
      end

      max = counts.sort_by{|x| x[:count] }.last

      return if max[:count] == 0

      y = counts.select {|x| x[:count] == max[:count] }

      names = y.map{|x| "<@#{x[:slack_id]}>"}.join(", ")

      "#{names} gave the most :+1: - #{max[:count]} PRs :100:"
    end

    def self.build_fastest_approver
      counts = Reviewer.all.map do |x|
        rels = x.pull_request_reviewer_relationships.
            where(approved_at: Time.current.beginning_of_day..Time.current.end_of_day)

        next if rels.count == 0

        {
          name: x.name,
          slack_id: x.slack_id,
          ave: ((rels.map{ |x| x.approved_at - x.created_at }.sum / rels.count)/60).ceil,
          count: rels.count,
        }
      end.compact

      counts.reject!{ |x| x[:ave] <= 1 }

      max = counts.sort_by{|x| x[:ave] }.first

      return if max.blank? || max[:count] <= 1

      y = counts.select {|x| x[:ave] == max[:ave] }

      names = y.map{|x| "<@#{x[:slack_id]}>"}.join(", ")

      "#{names} is the fastest :+1:'er averaging #{max[:ave]} minutes per PR :fast_parrot:"
    end

    def self.build_approval_speed
      rels = PullRequestReviewerRelationship.
        where(approved_at: Time.current.beginning_of_day..Time.current.end_of_day)
      approveds = rels.map{ |x| x.pull_request }.select{|x| x.approved? }

      return if rels.blank?

      t = approveds.map do |x|
        times = x.pull_request_reviewer_relationships.map{ |y| y.approved_at - x.created_at }
        max = times.max { |a,b| a <=> b }

        { title: x.title, url: x.url, approval_time: max }
      end

      t.reject!{ |x| x[:approval_time] <= 60 }

      return if t.blank?

      prs = t.sort_by{ |x| x[:approval_time] }
      fastest = prs.first
      slowest = prs.last

      if fastest[:url] == slowest[:url]
        "<#{fastest[:url]}|#{fastest[:title]}> was the only PR approved - #{(fastest[:approval_time]/60).ceil} minutes :clap:\n"
      else
        "<#{fastest[:url]}|#{fastest[:title]}> was the fastest PR approved - #{(fastest[:approval_time]/60).ceil} minutes :clap:\n" +
        "<#{slowest[:url]}|#{slowest[:title]}> was the slowest - #{(slowest[:approval_time]/60).ceil} minutes :scream:"
      end
    end
  end
end
