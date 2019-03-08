module Plankbot
  class SendDailyStats
    def self.execute
      return unless Setting.is_within_first_10_minutes_of_longest_shutdown?
      message = BuildDailyStats.execute

      Slack::Web::Client.new.chat_postMessage({
        channel: "coding",
        text: message.to_s + "\n\nGoodnight! :zzz:",
        as_user: true,
      })
    end
  end
end
