require "rails_helper"

module Plankbot
  describe PullRequest do
    before(:each) do
      Slack::Web::Client.any_instance.stub(:chat_postMessage).and_return true
    end

    specify do
      requestor = Reviewer.create({
        name: "requestor",
        slack_id: "slack_id",
        github_id: "github_id",
        available: true,
      })

      reviewer_1 = Reviewer.create({
        name: "reviewer",
        slack_id: "slack_id",
        github_id: "github_id",
        available: true,
      })

      reviewer_2 = Reviewer.create({
        name: "reviewer",
        slack_id: "slack_id",
        github_id: "github_id",
        available: true,
      })

      label = Label.create({
        name: "name",
      })

      pull_request_1 = PullRequest.create({
        title: "title",
        url: "github.com/xxx",
        github_id: "github_id",
        requestor: requestor,
      })

      pull_request_1.pull_request_label_relationships.create(label: label)

      pull_request_1.pull_request_reviewer_relationships.create({
        reviewer: reviewer_1,
      })

      pull_request_1.pull_request_reviewer_relationships.create({
        reviewer: reviewer_2,
        approved_at: DateTime.current,
      })

      pull_request_2 = PullRequest.create({
        title: "title",
        url: "github.com/xxx",
        github_id: "github_id",
        requestor: requestor,
      })

      pull_request_2.pull_request_label_relationships.create(label: label)

      pull_request_2.pull_request_reviewer_relationships.create({
        reviewer: reviewer_2,
        approved_at: DateTime.current,
      })

      expect(pull_request_1.requestor).to eq requestor
      expect(pull_request_1.reviewers).to match_array [reviewer_1, reviewer_2]
      expect(pull_request_1.unapproved_reviewers).to match_array [reviewer_1]
      expect(pull_request_1.approved_reviewers).to match_array [reviewer_2]
      expect(PullRequest.unapproved).to match_array [pull_request_1]
      expect(PullRequest.approved).to match_array [pull_request_1, pull_request_2]
      expect(pull_request_1.approval_count).to eq 1
      expect(pull_request_2.approval_count).to eq 1
      expect(pull_request_1.labels).to eq [label]
      expect(pull_request_2.labels).to eq [label]
    end
  end
end
