module Plankbot
  module CodeReview
    class SendDailyStats
      def self.execute
        return unless Setting.is_within_first_10_minutes_of_longest_shutdown?
        message = BuildDailyStats.execute

        return if message.to_s.blank?

        PLANKBOT_SLACK_CLIENT.chat_postMessage({
          channel: ENV["PLANKBOT_TECH_CODING_CHANNEL"],
          text: message.to_s + "\n\nGoodnight! :zzz:",
          as_user: true,
        })
      end
    end
  end
end
