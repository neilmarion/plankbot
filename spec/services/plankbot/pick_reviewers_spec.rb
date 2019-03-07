require "rails_helper"

module Plankbot
  describe PickReviewers do
    let(:available_tag) do
      Plankbot::Tag.create(name: "Yes", kind: "availability")
    end
    let(:not_available_tag) do
      Plankbot::Tag.create(name: "No", kind: "availability")
    end
    let(:time_1_tag) do
      Plankbot::Tag.create(name: "06:00-15:00", kind: "time_available")
    end
    let(:time_2_tag) do
      Plankbot::Tag.create(name: "07:00-16:00", kind: "time_available")
    end
    let(:time_3_tag) do
      Plankbot::Tag.create(name: "08:00-17:00", kind: "time_available")
    end
    let(:time_4_tag) do
      Plankbot::Tag.create(name: "09:00-18:00", kind: "time_available")
    end
    let(:onboarding_tag) do
      Plankbot::Tag.create(name: "onboarding", kind: "team")
    end
    let(:min_tag) do
      Plankbot::Tag.create(name: "min", kind: "team")
    end
    let(:mout_tag) do
      Plankbot::Tag.create(name: "mout", kind: "team")
    end
    let(:prodeng_tag) do
      Plankbot::Tag.create(name: "prodeng", kind: "team")
    end

    before(:each) do
      Slack::Web::Client.any_instance.stub(:chat_postMessage).and_return true
    end

    before(:each) do
      pr_counts = [1, 3, 6, 8, 2, 4, 4, 7, 0, 2]
      tags = [
        [available_tag, time_1_tag, onboarding_tag],
        [available_tag, time_1_tag, min_tag],
        [available_tag, time_1_tag, mout_tag],
        [available_tag, time_1_tag, prodeng_tag],
        [not_available_tag, time_1_tag, prodeng_tag],
        [available_tag, time_1_tag, min_tag],
        [available_tag, time_2_tag, mout_tag],
        [available_tag, time_2_tag, prodeng_tag],
        [available_tag, time_2_tag, min_tag],
        [available_tag, time_2_tag, min_tag],
      ]

      10.times.each do |x|
        reviewer = Plankbot::Reviewer.create(
          name: "Name #{x}",
          slack_id: "slack_id_#{x}",
          github_id: "github_id_#{x}",
        )

        pr_counts[x].times.each do |x|
          pull_request = Plankbot::PullRequest.create({
            title: "title_#{pr_counts[x]}_#{x}",
            url: "title_#{pr_counts[x]}_#{x}",
            github_id: "github_id_#{pr_counts[x]}_#{x}",
            requestor: requestor,
          })

          reviewer.pull_request_reviewer_relationships.create(
            reviewer: reviewer,
            pull_request: pull_request,
          )
        end

        tags[x].each do |tag|
          reviewer.reviewer_tag_relationships.create(tag: tag)
        end
      end
    end

    let(:requestor) do
      requestor = Plankbot::Reviewer.create({
        name: "Requestor",
        slack_id: "requestor_slack_id",
        github_id: "requestor_github_id"
      })

      requestor.reviewer_tag_relationships.create(tag: onboarding_tag)
      requestor
    end

    let(:review_ready_label) do
      Plankbot::Label.create(name: "review_ready")
    end

    let(:onboarding_label) do
      Plankbot::Label.create(name: "onboarding")
    end

    let(:min_label) do
      Plankbot::Label.create(name: "min")
    end

    describe OrderReviewersByPullRequestCount do
      specify do
        ctx = {chosen: [], remaining: [], pull_request: nil}
        ctx = OrderReviewersByPullRequestCount.execute(ctx)
        expect(ctx[:remaining].map(&:pull_request_count)).
          to eq [0, 0, 0, 1, 2, 3, 4, 4, 6, 7, 8]
      end
    end

    describe RemoveRequestor do
      specify do
        pull_request = Plankbot::PullRequest.create({
          title: "title",
          url: "url",
          github_id: "github_id",
          requestor: requestor,
        })

        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: pull_request}
        ctx = RemoveRequestor.execute(ctx)
        expect(ctx[:remaining].map(&:id).include? requestor.id).to be false
      end
    end

    describe FilterByAvailability do
      specify do
        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: nil}
        ctx = FilterByAvailability.execute(ctx)
        not_available_reviewers =
          ctx[:remaining].select{|x| x.tags.where(kind: "availability", name: "No").exists? }

        expect(not_available_reviewers).to be_blank
      end
    end

    describe FilterByTimeAvailable do
      specify do
        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: nil}
        allow(Time).to receive(:now).and_return Time.parse("15:30")
        ctx = FilterByTimeAvailable.execute(ctx)
        not_available_reviewers =
          ctx[:remaining].select{|x| x.tags.where(kind: "time_available", name: "06:00-15:00").exists? }

        expect(not_available_reviewers).to be_blank
      end
    end

    describe PickTeammate do
      specify do
        pull_request = Plankbot::PullRequest.create({
          title: "title",
          url: "url",
          github_id: "github_id",
          requestor: requestor,
        })

        pull_request.pull_request_label_relationships.create(label: onboarding_label)

        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: pull_request}
        ctx = PickTeammate.execute(ctx)
        non_teammate_reviewers =
          ctx[:chosen].select{|x| x.tags.where(kind: "team").where.not(name: onboarding_tag.name).exists? }

        expect(non_teammate_reviewers).to be_blank
      end
    end

    describe PickWithLeastAssignment do
      it "chooses reviewers with least assignments" do
        pull_request = Plankbot::PullRequest.create({
          title: "title",
          url: "url",
          github_id: "github_id",
          requestor: requestor,
        })

        pull_request.pull_request_label_relationships.create(label: onboarding_label)
        pull_request.pull_request_label_relationships.create(label: review_ready_label)

        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: pull_request}
        ctx = OrderReviewersByPullRequestCount.execute(ctx)
        ctx = PickWithLeastAssignment.execute(ctx)
        expect(ctx[:chosen].count).to eq 2
        ctx[:chosen].each do |c|
          ctx[:remaining].each do |r|
            expect(c.pull_request_count <= r.pull_request_count).to be true
          end
        end
      end

      it "only chooses teammates with least assignments according to reviewer count" do
        pull_request = Plankbot::PullRequest.create({
          title: "title",
          url: "url",
          github_id: "github_id",
          requestor: requestor,
        })

        pull_request.pull_request_label_relationships.create(label: min_label)
        pull_request.pull_request_label_relationships.create(label: review_ready_label)
        min_reviewers = Plankbot::Tag.find_by_name(min_label.name).reviewers

        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: pull_request}
        ctx = OrderReviewersByPullRequestCount.execute(ctx)
        ctx = PickTeammate.execute(ctx)
        ctx = PickWithLeastAssignment.execute(ctx)
        expect(ctx[:chosen].count).to eq 2
        ctx[:chosen].each do |c|
          min_reviewers.where.not(id: ctx[:chosen].map(&:id)).each do |r|
            expect(c.pull_request_count <= r.pull_request_count).to be true
          end
        end
      end

      it "only chooses teammates with least assignments according to reviewer count" do
        pull_request = Plankbot::PullRequest.create({
          title: "title",
          url: "url",
          github_id: "github_id",
          requestor: requestor,
        })

        pull_request.pull_request_label_relationships.create(label: min_label)
        pull_request.pull_request_label_relationships.create(label: review_ready_label)
        min_reviewers = Plankbot::Tag.find_by_name(min_label.name).reviewers

        ctx = {chosen: [], remaining: Plankbot::Reviewer.all.to_a, pull_request: pull_request}
        ctx = OrderReviewersByPullRequestCount.execute(ctx)
        ctx = PickTeammate.execute(ctx)
        ctx = PickWithLeastAssignment.execute(ctx)
        expect(ctx[:chosen].count).to eq 2
        ctx[:chosen].each do |c|
          min_reviewers.where.not(id: ctx[:chosen].map(&:id)).each do |r|
            expect(c.pull_request_count <= r.pull_request_count).to be true
          end
        end
      end
    end

    specify do
      pull_request = Plankbot::PullRequest.create({
        title: "title",
        url: "url",
        github_id: "github_id",
        requestor: requestor,
      })

      pull_request.pull_request_label_relationships.
        create(label: review_ready_label)

      pull_request.pull_request_label_relationships.
        create(label: onboarding_label)

      allow(Time).to receive(:now).and_return Time.parse("14:00")

      chosen_reviewers = PickReviewers.execute(pull_request: pull_request)
      expect(chosen_reviewers.count).to eq 2
      expect(chosen_reviewers.map(&:slack_id)).to match_array ["slack_id_0", "slack_id_8"]
    end
  end
end
