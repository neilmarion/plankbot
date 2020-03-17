module Plankbot
  class Presence < ApplicationRecord
    after_create :announce

    belongs_to :requestor, {
      foreign_key: :requestor_id,
      class_name: "Reviewer",
    }

    SLACK = "slack".freeze
    PLANKBOT = "plankbot".freeze

    def announce
      return if self.kind == SLACK
      date_now = (DateTime.now + 8.hours).to_date.to_s

      slack_channels = JSON.parse(ENV["PLANKBOT_TEAM_TAG_SLACK_CHANNELS"])
      slack_channels.each do |k, channel|
        next unless self.requestor.tags.where(kind: "team").exists?(name: k) || k == "all"

        e_note = if self.note
                  "_(#{self.note})_"
                 else
                  ""
                 end

        begin
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: channel,
            text: "<#{ENV["PLANKBOT_HOST"]}/attendances?date=#{date_now}|#{self.requestor.name}> is #{self.is_online ? "SIGNING IN :sunrise_over_mountains:" : "SIGNING OUT :last_quarter_moon_with_face:"} #{e_note}",
            as_user: true,
          )
        rescue Slack::Web::Api::Errors::SlackError => e
        end
      end
    end
  end
end
