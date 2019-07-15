module Plankbot
  class SendDailyScrumCeremonies
    def self.execute
      s = JSON.parse(ENV["PLANKBOT_SCRUM_SCHEDULE"])

      s.each do |k, v|
        day = (Time.current + 1.day).strftime('%A')
        schedule = v["schedule"][day.downcase]

        return unless schedule

        schedule_message = schedule["ceremonies"].each_with_index.map do |s, i|
          "#{i+1}) *#{s["ceremony"]}* #{s["time"]}"
        end

        v["people"].map do |x|
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: x["slack_id"],
            text: "Hey #{x["name"]}, these are scrum ceremonies for tomorrow (#{day}):\n\n#{schedule_message.join("\n")}\n\n",
            as_user: true,
          )
        end
      end
    end
  end
end
