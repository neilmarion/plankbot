require "rails_helper"

module Plankbot
  describe Reviewer do
    before(:each) do
      Slack::Web::Client.any_instance.stub(:chat_postMessage).and_return true
    end

    specify do
      tag_1 = Tag.create({
        name: "name",
        kind: "kind",
        description: "description"
      })

      tag_2 = Tag.create({
        name: "name",
        kind: "kind",
        description: "description"
      })

      requestor = Reviewer.create({
        name: "requestor",
        slack_id: "slack_id",
        github_id: "github_id",
        available: false,
      })

      reviewer_1 = Reviewer.create({
        name: "reviewer",
        slack_id: "slack_id",
        github_id: "github_id",
        available: true,
      })

      reviewer_1.reviewer_tag_relationships.create(tag: tag_1)

      reviewer_2 = Reviewer.create({
        name: "reviewer",
        slack_id: "slack_id",
        github_id: "github_id",
        available: true,
      })

      reviewer_2.reviewer_tag_relationships.create(tag: tag_2)

      label = Label.create({
        name: "name",
      })

      pull_request_1 = PullRequest.create({
        title: "title",
        url: "github.com/xxx",
        github_id: "github_id",
        requestor: requestor,
      })

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

      pull_request_2.pull_request_reviewer_relationships.create({
        reviewer: reviewer_2,
        approved_at: DateTime.current,
      })

      expect(reviewer_1.tags).to match_array [tag_1]
      expect(reviewer_2.tags).to match_array [tag_2]

      expect(reviewer_1.pull_requests).to match_array [pull_request_1]
      expect(reviewer_1.unapproved_pull_requests).to match_array [pull_request_1]
      expect(reviewer_1.approved_pull_requests).to match_array []

      expect(reviewer_2.pull_requests).to match_array [pull_request_1, pull_request_2]
      expect(reviewer_2.unapproved_pull_requests).to match_array []
      expect(reviewer_2.approved_pull_requests).to match_array [pull_request_1, pull_request_2]

      expect(Reviewer.available).to eq [reviewer_1, reviewer_2]
      expect(Reviewer.unavailable).to eq [requestor]

      expect(Reviewer.unapproved).to match_array [reviewer_1]
      expect(Reviewer.approved).to match_array [reviewer_2]
    end
  end
end
