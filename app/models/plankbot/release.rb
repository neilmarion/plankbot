module Plankbot
  class Release < ApplicationRecord
    has_many :release_issues, dependent: :destroy

    def announce
      issues = release_issues.map.with_index do |issue, i|
        "#{i+1}) _#{issue.issue_type}_ *#{issue.summary}* <https://firstcircle.atlassian.net/browse/#{issue.key}|jira>"
      end

      begin
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_RELEASE_NOTES_SLACK_CHANNEL"],
          text: ":arrow_up: <https://firstcircle.atlassian.net/projects/#{team}/versions/#{jira_id}|#{name}>\ndescription: *#{description}*\nstart: *#{start_date&.strftime("%d-%b-%Y")}*\nrelease: *#{release_date&.strftime("%d-%b-%Y")}*\n\n#{issues.join("\n")}",
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
