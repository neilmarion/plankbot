require "rails_helper"

module Plankbot
  describe EtlPullRequests, vcr: { record: :once } do
    before(:each) do
      available_tag = Plankbot::Tag.create(name: "Yes", kind: "availability")
      not_available_tag = Plankbot::Tag.create(name: "No", kind: "availability")
      time_1_tag = Plankbot::Tag.create(name: "06:00-15:00", kind: "time_available")
      time_2_tag = Plankbot::Tag.create(name: "07:00-16:00", kind: "time_available")
      time_3_tag = Plankbot::Tag.create(name: "08:00-17:00", kind: "time_available")
      time_4_tag = Plankbot::Tag.create(name: "09:00-18:00", kind: "time_available")
      onboarding_tag = Plankbot::Tag.create(name: "onboarding", kind: "team")
      min_tag = Plankbot::Tag.create(name: "min", kind: "team")
      mout_tag = Plankbot::Tag.create(name: "mout", kind: "team")
      prodeng_tag = Plankbot::Tag.create(name: "prodeng", kind: "team")
      data_tag = Plankbot::Tag.create(name: "data", kind: "team")
      design_tag = Plankbot::Tag.create(name: "design", kind: "team")
      management_tag = Plankbot::Tag.create(name: "management", kind: "team")
      product_tag = Plankbot::Tag.create(name: "product", kind: "team")
      qa_tag = Plankbot::Tag.create(name: "qa", kind: "team")
      high_sensitivity_tag = Plankbot::Tag.create(name: "high_sensitivity", kind: "tier")

      reviewers = {
        jessc: {name: "Jess", slack_id: "U4SK3RBPS", github_id: "jmalvinchin", tags: [available_tag, time_1_tag, min_tag]},
        dc: {name: "Dean", slack_id: "U4SK3RBPS", github_id: "dc-fc", tags: [available_tag, time_1_tag, min_tag]},
        earle: {name: "Earle", slack_id: "U4SK3RBPS", github_id: "erbunao", tags: [available_tag, time_4_tag, prodeng_tag]},
        francis: {name: "Francis", slack_id: "U4SK3RBPS", github_id: "sic-f", tags: [available_tag, time_4_tag, mout_tag]},
        nmfdelacruz: {name: "Neil", slack_id: "U4SK3RBPS", github_id: "neilmarion", tags: [available_tag, time_4_tag, onboarding_tag]},
        rickdtrick: {name: "Rick", slack_id: "U4SK3RBPS", github_id: "rickdtrick", tags: [available_tag, time_4_tag, onboarding_tag]},
        angelique: {name: "Anj", slack_id: "U4SK3RBPS", github_id: "angeliqueulep", tags: [available_tag, time_4_tag, prodeng_tag]},
        jan: {name: "Jan", slack_id: "U4SK3RBPS", github_id: "fc-janharold", tags: [not_available_tag, time_4_tag, design_tag]},
        tj: {name: "TJ", slack_id: "U4SK3RBPS", github_id: "tjpalanca", tags: [not_available_tag, time_4_tag, data_tag]},
        andrewe: {name: "Andrew E", slack_id: "U4SK3RBPS", github_id: "aescay", tags: [not_available_tag, time_4_tag, data_tag]},
        tony: {name: "Tony", slack_id: "U4SK3RBPS", github_id: "tonyennis145", tags: [not_available_tag, time_4_tag, management_tag, high_sensitivity_tag]},
        brian: {name: "Brian", slack_id: "U4SK3RBPS", github_id: "briandragon", tags: [not_available_tag, time_4_tag, management_tag]},
        jerico: {name: "Jerico", slack_id: "U4SK3RBPS", github_id: "jericoramirez", tags: [not_available_tag, time_4_tag, qa_tag]},
        jig: {name: "Jig", slack_id: "U4SK3RBPS", github_id: "JigFirstCircle", tags: [not_available_tag, time_4_tag, product_tag]},
        rj: {name: "RJ", slack_id: "U4SK3RBPS", github_id: "rjomosura", tags: [not_available_tag, time_4_tag, qa_tag]},
      }

      reviewers.each do |reviewer|
        value = reviewer.last
        reviewer = Plankbot::Reviewer.
          create({
          name: value[:name],
          slack_id: value[:slack_id],
          github_id: value[:github_id],
        })

        value[:tags].each do |tag|
          reviewer.reviewer_tag_relationships.create(tag: tag)
        end
      end

      labels = [
        "review_ready",
        "release",
        "onboarding",
        "min",
        "mout",
        "prodeng",
        "high_sensitivity",
        "fca",
        "fcc",
        "website",
      ]

      labels.each do |key|
        Plankbot::Label.create(name: key)
      end
    end

    specify do
      Plankbot::Setting.create({
        shutdown_times: ["18:00-06:00", "12:00-13:00"],
      })

      allow(Time).to receive(:current).and_return Time.parse("15:00")
      EtlPullRequests.execute
      expect(Plankbot::PullRequest.count).to eq 6
      expect(Plankbot::PullRequestReviewerRelationship.count).to eq 14

      expect(Plankbot::Reviewer.find_by_github_id("jmalvinchin").pull_requests.count).to eq 2
      expect(Plankbot::Reviewer.find_by_github_id("dc-fc").pull_requests.count).to eq 1
      expect(Plankbot::Reviewer.find_by_github_id("erbunao").pull_requests.count).to eq 3
      expect(Plankbot::Reviewer.find_by_github_id("sic-f").pull_requests.count).to eq 1
      expect(Plankbot::Reviewer.find_by_github_id("neilmarion").pull_requests.count).to eq 2
      expect(Plankbot::Reviewer.find_by_github_id("rickdtrick").pull_requests.count).to eq 3
      expect(Plankbot::Reviewer.find_by_github_id("angeliqueulep").pull_requests.count).to eq 1
      expect(Plankbot::Reviewer.find_by_github_id("fc-janharold").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("tjpalanca").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("aescay").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("tonyennis145").pull_requests.count).to eq 1
      expect(Plankbot::Reviewer.find_by_github_id("briandragon").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("jericoramirez").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("JigFirstCircle").pull_requests.count).to eq 0
      expect(Plankbot::Reviewer.find_by_github_id("rjomosura").pull_requests.count).to eq 0

      expected_result =[
        {:url=>"https://github.com/carabao-capital/first-circle-app/pull/3450", :reviewers=>[{:name=>"Francis", :approved=>true}, {:name=>"Neil", :approved=>true}]},
        {:url=>"https://github.com/carabao-capital/first-circle-app/pull/3446", :reviewers=>[{:name=>"Jess", :approved=>true}, {:name=>"Earle", :approved=>true}, {:name=>"Neil", :approved=>true}]},
        {:url=>"https://github.com/carabao-capital/first-circle-app/pull/3432", :reviewers=>[{:name=>"Jess", :approved=>true}, {:name=>"Rick", :approved=>true}, {:name=>"Tony", :approved=>false}]},
        {:url=>"https://github.com/carabao-capital/first-circle-app/pull/3425", :reviewers=>[{:name=>"Earle", :approved=>false}, {:name=>"Anj", :approved=>true}]},
        {:url=>"https://github.com/carabao-capital/first-circle-app/pull/3420", :reviewers=>[{:name=>"Dean", :approved=>true}, {:name=>"Rick", :approved=>true}]},
        {:url=>"https://github.com/carabao-capital/first-circle-account/pull/482", :reviewers=>[{:name=>"Earle", :approved=>true}, {:name=>"Rick", :approved=>true}]},
      ]

      actual_result = Plankbot::PullRequest.all.map do |x|
        {
          url: x.url,
          reviewers: x.reviewers.map do |y|
            {name: y.name,
             approved: x.
              pull_request_reviewer_relationships.
              find_by_reviewer_id(y.id).approved_at != nil}
          end
        }
      end

      expect(actual_result).to match_array expected_result

      EtlPullRequests.execute

      actual_result = Plankbot::PullRequest.all.map do |x|
        {
          url: x.url,
          reviewers: x.reviewers.map do |y|
            {name: y.name,
             approved: x.
              pull_request_reviewer_relationships.
              find_by_reviewer_id(y.id).approved_at != nil}
          end
        }
      end

      expect(actual_result).to match_array expected_result

      # SendDailyStats.execute

      # NOTE: Reminders
      RemindReviewers.execute
    end

    it "does not run if within shutdown times" do
      Plankbot::Setting.create({
        shutdown_times: ["18:00-06:00", "12:00-13:00"],
        shutdown_week_days: ["Saturday", "Sunday"],
        shutdown_dates: ["2019-02-24"],
      })

      allow(Time).to receive(:current).and_return Time.parse("19:00")
      EtlPullRequests.execute
      expect(Plankbot::PullRequest.count).to eq 0

      allow(Time).to receive(:current).and_return Time.parse("2019-03-02")
      EtlPullRequests.execute
      expect(Plankbot::PullRequest.count).to eq 0

      allow(Time).to receive(:current).and_return Time.parse("2019-02-24")
      EtlPullRequests.execute
      expect(Plankbot::PullRequest.count).to eq 0
    end

    it "says goodnight and sends stats when within longest shutdown time" do
      Plankbot::Setting.create({
        shutdown_times: ["18:00-06:00", "12:00-13:00"],
        shutdown_week_days: ["Saturday", "Sunday"],
        shutdown_dates: ["2019-02-24"],
      })

      allow(Time).to receive(:current).and_return Time.parse("12:05")
      expect(Plankbot::Setting.is_within_first_10_minutes_of_longest_shutdown?).to eq false

      allow(Time).to receive(:current).and_return Time.parse("07:00")
      expect(Plankbot::Setting.is_within_first_10_minutes_of_longest_shutdown?).to eq false

      allow(Time).to receive(:current).and_return Time.parse("19:00")
      expect(Plankbot::Setting.is_within_first_10_minutes_of_longest_shutdown?).to eq false

      allow(Time).to receive(:current).and_return Time.parse("18:10")
      expect(Plankbot::Setting.is_within_first_10_minutes_of_longest_shutdown?).to eq true
    end

    it "can be indefinitely shutdown" do
      Plankbot::Setting.create({
        shutdown_dates: ["*"],
      })

      expect(Plankbot::Setting.is_shutdown?).to eq true
    end
  end
end
