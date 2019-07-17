module Plankbot
  class CriticalIssue < ApplicationRecord
    def announce
      note = "_1. A time-box is given to the scrum team to investigate._\n" +
        "_2. If investigation went beyond the time-box, PO can decide to notify the Platform team that a rollback is needed (FCC and/or FCA). Two things will happen then:_\n" +
        "\ \ \ \ _a) Platform team will disable auto-deployments to production; although teams can still merge to master during the period._\n" +
        "\ \ \ \ _b) Platform team will rollback production to the healthy version in Cloud66._\n" +
        "_3. Before releasing the fix, PO (or anyone from the scrum team) must notify the Platform team to re-enable auto-deployment._"
      text = ":warning: *Critical Issue Created*\nsummary: <https://firstcircle.atlassian.net/browse/#{key}|#{key}> #{summary}\nreporter: #{reporter}\n"

      begin
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_CRITICAL_ISSUE_ANNOUNCEMENT_CHANNEL"],
          text: text + "\n" + note,
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
