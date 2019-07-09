module Plankbot
  class Release < ApplicationRecord
    has_many :release_issues, dependent: :destroy

    TEAM_SLACK_IDS = {
      "CJE" => "(PO) <@UFE78H79U>, (Lead) <@U5VFECCPM>, (Eng) <@U4TDX4QSH> <@UH83SB649> <@UJG3JHHEF>, (QA) <@UJSDQ82LB>",
      "UP" => "(PO) <@U2DHPSA9J>, (Lead) <@U6N5LSTJR>, (Eng) <@UH5GJ1ZKL>, (QA) <@UHJ77HHE2>",
      "ORIG" => "(PO) <@UC89TQME3>, (Lead) <@U5RT71ZKQ>, (Eng) <@UHGQM9N76> <@UKNT1DNCR>, (QA) <@UKDS7QUJC>",
      "PFM" => "<@UHECKLPMW> <@U4SK3RBPS>",
    }

    def announce
      issues = release_issues.map.with_index do |issue, i|
        next if i >= 15

        "#{i+1}) _#{issue.issue_type}_ *#{issue.summary}* <https://firstcircle.atlassian.net/browse/#{issue.key}|jira>"
      end.compact

      begin
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_RELEASE_NOTES_SLACK_CHANNEL"],
          text: ":arrow_up: <https://firstcircle.atlassian.net/projects/#{team}/versions/#{jira_id}|#{name}>\ndescription: *#{description}*\nstart: *#{start_date&.strftime("%d-%b-%Y")}*\nrelease: *#{release_date&.strftime("%d-%b-%Y")}*\nteam: *#{TEAM_SLACK_IDS[team]}*\n\n#{issues.join("\n")}\n#{issues.count > 14 ? "_...Stories list redacted_" : ""}",
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
