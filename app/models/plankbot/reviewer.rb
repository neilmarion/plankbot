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
  end
end
