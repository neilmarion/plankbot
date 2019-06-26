module Plankbot
  class SendDailyStats
    def self.execute
      return unless Setting.is_within_first_10_minutes_of_longest_shutdown?
      message = BuildDailyStats.execute

      PLANKBOT_SLACK_CLIENT.chat_postMessage({
        channel: "tech_coding",
        text: message.to_s + "\n\nGoodnight! :zzz:",
        as_user: true,
      })
    end
  end
end
