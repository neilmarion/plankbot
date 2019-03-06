module Plankbot
  class PullRequest < ApplicationRecord
    has_many :pull_request_reviewer_relationships, dependent: :destroy
    has_many :reviewers, through: :pull_request_reviewer_relationships

    has_many :pull_request_label_relationships
    has_many :labels, through: :pull_request_label_relationships

    belongs_to :requestor, {
      foreign_key: :requestor_id,
      class_name: "Reviewer",
    }

    has_many :unapproved_pull_request_reviewer_relationships, -> { unapproved }, {
      class_name: "PullRequestReviewerRelationship"
    }

    has_many :unapproved_reviewers, {
      through: :unapproved_pull_request_reviewer_relationships,
    }

    has_many :approved_pull_request_reviewer_relationships, -> { approved }, {
      class_name: "PullRequestReviewerRelationship"
    }

    has_many :approved_reviewers, {
      through: :approved_pull_request_reviewer_relationships,
    }

    scope :unapproved, -> do
      joins(:pull_request_reviewer_relationships).where({
        plankbot_pull_request_reviewer_relationships: { approved_at: nil },
      }).distinct
    end

    scope :approved, -> do
      joins(:pull_request_reviewer_relationships).where.not({
        plankbot_pull_request_reviewer_relationships: { approved_at: nil },
      }).distinct
    end

    def approval_count
      approved_reviewers.count
    end

    def approved?
      unapproved_reviewers.blank?
    end

    def ping_reviewers
      self.pull_request_reviewer_relationships.map(&:ping_reviewer)
    end

    def destroy_with_ping
      ping_requestor_about_destroy if self.destroy
    end

    private

    def ping_requestor_about_destroy
      Slack::Web::Client.new.chat_postMessage(
        channel: requestor.slack_id,
        text: "I removed <#{url}|#{title}> from my database. Maybe one of the reviewer have request changes? :man-tipping-hand:",
        as_user: true,
      )
    end
  end
end
