module Plankbot
  module CodeReview
    class TransformPullRequests
      TRIGGER_LABELS = [
        PickWithLeastAssignment::REVIEW_READY_LABEL,
        PickWithLeastAssignment::RELEASE_LABEL,
      ]

      THUMBS_UP = /\:\+1\:|👍/

      def self.execute(extracted_pull_requests)
        pull_requests = extracted_pull_requests.map do |pr|
          labels = pr["labels"].map { |x| x["name"] }
          next unless (labels & TRIGGER_LABELS).present?

          repo_label = get_repo_label(pr)
          dept_label = get_repo_dept_label(pr)
          labels << repo_label if repo_label
          labels << dept_label if dept_label

          comments = fetch_comments(pr["comments_url"])
          approvers = comments.map do |comment|
            next unless comment["body"].match? THUMBS_UP
            comment["user"]["login"]
          end.compact

          {
            title: pr["title"],
            url: pr["html_url"],
            github_id: pr["id"].to_s,
            requestor_github_id: pr["user"]["login"].to_s,
            labels: labels,
            approvers: approvers,
          }
        end

        pull_requests.compact
      end

      private

      def self.get_repo_label(pr)
        repos = JSON.parse(ENV["PLANKBOT_REPOS"])

        chosen_repos = repos.select do |repo|
          pr["url"].match?(Regexp.new(repo["github_repo"]))
        end

        chosen_repos.first["label"] if chosen_repos.present?
      end

      def self.get_repo_dept_label(pr)
        repos = JSON.parse(ENV["PLANKBOT_REPOS"])

        chosen_repos = repos.select do |repo|
          pr["url"].match?(Regexp.new(repo["github_repo"]))
        end

        chosen_repos.first["dept"] if chosen_repos.present?
      end

      def self.fetch_comments(url)
        response = HTTParty.
          get(url + "?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}")
        response.parsed_response
      end
    end
  end
end
