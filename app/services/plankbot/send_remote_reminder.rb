module Plankbot
  class SendRemoteReminder
    def self.execute
      people = Plankbot::Reviewer.where.not(bamboohr_id: nil).where.not(bamboohr_id: ENV["PLANKBOT_REMIND_REMOTE_EXCEPT"].split(','))

      date_now = (DateTime.now + 8.hours).to_date
      return if date_now.friday? || date_now.saturday?

      people.each do |x|
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: x.slack_id,
          text: "Hi #{x.name}, please file your remote in <https://firstcircle.bamboohr.com/home|BambooHR> if you are having one tomorrow (#{date_now.tomorrow}). :+1:",
          as_user: true,
        )
      end
    end
  end
end
