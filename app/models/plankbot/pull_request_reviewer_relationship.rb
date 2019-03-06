module Plankbot
  class PullRequestReviewerRelationship < ApplicationRecord
    belongs_to :reviewer
    belongs_to :pull_request

    has_one :unapproved_pull_request, -> { unapproved }, {
      class_name: "Plankbot::PullRequest",
      foreign_key: :id,
      primary_key: :pull_request_id
    }
    has_one :unapproved_reviewer, -> { unapproved }, {
      class_name: "Plankbot::Reviewer",
      foreign_key: :id,
      primary_key: :reviewer_id
    }

    has_one :approved_pull_request, -> { approved }, {
      class_name: "Plankbot::PullRequest",
      foreign_key: :id,
      primary_key: :pull_request_id
    }
    has_one :approved_reviewer, -> { approved }, {
      class_name: "Plankbot::Reviewer",
      foreign_key: :id,
      primary_key: :reviewer_id
    }

    scope :unapproved, -> { where({ approved_at: nil }) }
    scope :approved, -> { where.not({ approved_at: nil }) }

    after_create :ping_reviewer
    after_update :ping_requestor

    def ping_reviewer
      begin
        Slack::Web::Client.new.chat_postMessage(
          channel: reviewer.slack_id,
          text: "#{self.pull_request.requestor.name} wants you to review their PR <#{self.pull_request.url}|#{self.pull_request.title}> :pray: :mag_right:",
          as_user: true,
        ) unless self.approved_at
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end

    def ping_requestor
      begin
        Slack::Web::Client.new.chat_postMessage({
          channel: self.pull_request.requestor.slack_id,
          text: "Great! Your PR <#{self.pull_request.url}|#{self.pull_request.title}> has been approved by #{self.pull_request.reviewers.pluck(:name).join(" and ")} :100: :fast_parrot:",
          as_user: true,
        }) if changes["approved_at"].present? &&
        self.reload.pull_request.approved?
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
