module Plankbot
  class Reviewer < ApplicationRecord
    attr_accessor :pull_request_count, :pull_request_count_for_the_day

    has_many :requested_pull_requests, {
      primary_key: :id,
      foreign_key: :requestor_id,
      class_name: "PullRequest",
    }

    has_many :pull_request_reviewer_relationships
    has_many :pull_requests, through: :pull_request_reviewer_relationships

    has_many :reviewer_tag_relationships
    has_many :tags, through: :reviewer_tag_relationships

    accepts_nested_attributes_for :reviewer_tag_relationships, {
      allow_destroy: true
    }

    has_many :unapproved_pull_request_reviewer_relationships, -> { unapproved }, {
      class_name: "PullRequestReviewerRelationship"
    }

    has_many :unapproved_pull_requests, {
      through: :unapproved_pull_request_reviewer_relationships
    }

    has_many :approved_pull_request_reviewer_relationships, -> { approved }, {
      class_name: "PullRequestReviewerRelationship"
    }

    has_many :approved_pull_requests, {
      through: :approved_pull_request_reviewer_relationships
    }

    has_many :attendances, {
      primary_key: :id,
      foreign_key: :requestor_id,
      class_name: "Attendance",
    }

    has_many :presences, {
      primary_key: :id,
      foreign_key: :requestor_id,
      class_name: "Presence",
    }

    scope :available, -> { where(available: true) }
    scope :unavailable, -> { where(available: false) }

    scope :unapproved, -> do
      joins(:pull_request_reviewer_relationships).where({
        plankbot_pull_request_reviewer_relationships: {approved_at: nil}
      }).distinct
    end

    scope :approved, -> do
      joins(:pull_request_reviewer_relationships).where.not({
        plankbot_pull_request_reviewer_relationships: {approved_at: nil}
      }).distinct
    end

    def pull_request_count
      @pull_request_count ||= pull_requests.count
    end

    def pull_request_count_for_the_day
      @pull_request_count_for_the_day ||=
        pull_requests.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count
    end

    def is_available?
      return tags.
        where(kind: "availability").
        pluck(:name).
        include? CodeReview::FilterByAvailability::YES_TAG
    end

    def online_in_slack?(date)
      presence = presences.where(kind: "slack").last
      return false unless presence
      return false if date != (presence.from).to_date

      presence.is_online
    end

    def signed_in?(date)
      presence = presences.where(kind: "plankbot").last
      return false unless presence
      return false if date != (presence.from).to_date

      presence.is_online
    end

    def total_time_in_today_secs(date)
      sum_in_sec = 0
      presences_today(date).map do |p|
        sum_in_sec = sum_in_sec + ((p.to || Time.current) - p.from)
      end
      sum_in_sec
    end

    def total_time_in_today_readable(date)
      sec = total_time_in_today_secs(date)
      "%02d:%02d:%02d" % [sec / 3600, sec / 60 % 60, sec % 60]
    end

    def signed_in_time(date)
      presences_today(date).first&.from&.strftime("%H:%M")
    end

    def signed_out_time(date)
      presences_today(date).last&.to&.strftime("%H:%M")
    end

    def presences_today(date=Time.current)
      presences.where(kind: 'plankbot', is_online: true, created_at: date.beginning_of_day..date.end_of_day).order(:created_at)
    end

    def attendance(date)
      return "Weekend" if date.saturday? || date.sunday?
      attendances.find_by(date: date)&.kind&.downcase || "Office"
    end

    def department
      tags.find_by(kind: "department")&.name
    end

    def presence_ranges(date)
      signed_in_time = presences_today(date).first&.from
      return [{ percentage: 100, status: 'remaining' }] unless signed_in_time

      secs = total_time_in_today_secs(date)

      remaining = 8.hours.to_i - secs

      current_time = Time.current.to_date == date ? Time.current : signed_in_time + secs + remaining
      end_time = if remaining.positive?
        current_time + remaining
      else
        current_time
      end

      span_secs = end_time - signed_in_time

      pcs = presences.where(kind: 'plankbot', created_at: date.beginning_of_day..date.end_of_day).order(:created_at)

      result = pcs.each_with_object([]) do |pcs, arr|
        s = (pcs.to || current_time) - pcs.from
        percentage = (s.to_f / span_secs.to_f) * 100.00
        next if percentage.negative?
        arr << { percentage: [percentage, 100].min, status: pcs.is_online ? 'in' : 'out' }
      end.compact

      return [{ percentage: 100, status: 'remaining' }] if result.blank?

      if result.first[:status] == 'out'
        result = result.drop(1)
      end

      result << { percentage: ((end_time - current_time).to_f / span_secs.to_f) * 100.00, status: 'remaining' }
    end
  end
end
