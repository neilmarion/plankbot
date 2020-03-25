module Plankbot
  class Release < ApplicationRecord
    has_many :release_issues, dependent: :destroy
    has_many :release_pull_requests, dependent: :destroy
    after_create :retrieve_and_create_release_prs

    FCC_CLOSED_PULL_REQUESTS = "https://api.github.com/repos/carabao-capital/first-circle-app/pulls?state=closed&access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}"
    FCA_CLOSED_PULL_REQUESTS = "https://api.github.com/repos/carabao-capital/first-circle-account/pulls?state=closed&access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}"
    LMS_API_CLOSED_PULL_REQUESTS = "https://api.github.com/repos/carabao-capital/first-circle-lms/pulls?state=closed&access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}"
    LMS_FE_CLOSED_PULL_REQUESTS = "https://api.github.com/repos/carabao-capital/lms-frontend/pulls?state=closed&access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}"

    def announce
      issues = release_issues.map.with_index do |issue, i|
        next if i >= 15

        "#{i+1}) _#{issue.issue_type}_ *#{issue.summary}* <https://www.pivotaltracker.com/story/show/#{issue.key}|tracker>"
      end.compact

      pull_requests = release_pull_requests.map.with_index do |pr, i|
        "<#{pr.url}|#{pr.repo}>"
      end.compact

      begin
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_RELEASE_NOTES_SLACK_CHANNEL"],
          text: ":arrow_up: <https://www.pivotaltracker.com/story/show/#{jira_id}|#{name}>\ndescription: *#{description}*\nstart: *#{start_date&.strftime("%d-%b-%Y")}*\nrelease: *#{release_date&.strftime("%d-%b-%Y")}*\nteam: *#{JSON.parse(ENV["PLANKBOT_TEAM_SLACK_IDS"])[team]}*\npull requests: #{pull_requests.join(" ")}\n\n#{issues.join("\n")}\n#{issues.count > 14 ? "_...Stories list redacted_" : ""}",
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end

    private

    def retrieve_and_create_release_prs
      retrieve_and_create_fcc_release_prs
      retrieve_and_create_fca_release_prs
      retrieve_and_create_lms_api_release_prs
      retrieve_and_create_lms_fe_release_prs
    end

    def retrieve_and_create_fcc_release_prs
      fcc_version = name.match(/FCC[ |-]([0-9]*.[0-9]*.[0-9]*)/).try(:[], 1)
      return if fcc_version.blank?

      fcc_pull_requests = HTTParty.get(FCC_CLOSED_PULL_REQUESTS)
      pr = fcc_pull_requests.select{ |pr| pr["title"] == fcc_version }.first

      return unless pr
      release_pull_requests.create(repo: "first-circle-app", url: pr["html_url"])
    end

    def retrieve_and_create_fca_release_prs
      fca_version = name.match(/FCA[ |-]([0-9]*.[0-9]*.[0-9]*)/).try(:[], 1)
      return if fca_version.blank?

      fca_pull_requests = HTTParty.get(FCA_CLOSED_PULL_REQUESTS)
      pr = fca_pull_requests.select{ |pr| pr["title"] == fca_version }.first

      return unless pr
      release_pull_requests.create(repo: "first-circle-account", url: pr["html_url"])
    end

    def retrieve_and_create_lms_api_release_prs
      lms_api_version = name.match(/FCA[ |-]([0-9]*.[0-9]*.[0-9]*)/).try(:[], 1)
      return if lms_api_version.blank?

      lms_api_pull_requests = HTTParty.get(LMS_API_CLOSED_PULL_REQUESTS)
      pr = lms_api_pull_requests.select{ |pr| pr["title"] == lms_api_version }.first

      return unless pr
      release_pull_requests.create(repo: "first-circle-lms", url: pr["html_url"])
    end

    def retrieve_and_create_lms_fe_release_prs
      lms_fe_version = name.match(/FCA[ |-]([0-9]*.[0-9]*.[0-9]*)/).try(:[], 1)
      return if lms_fe_version.blank?

      lms_fe_pull_requests = HTTParty.get(LMS_FE_CLOSED_PULL_REQUESTS)
      pr = lms_fe_pull_requests.select{ |pr| pr["title"] == lms_fe_version }.first

      return unless pr
      release_pull_requests.create(repo: "lms-frontend", url: pr["html_url"])
    end
  end
end
