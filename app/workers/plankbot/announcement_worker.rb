module Plankbot
  class AnnouncementWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform(channel, message)
      case channel
      when "engineers_in_bamboohr"
        people = Plankbot::Reviewer.where.not(bamboohr_id: nil).where.not(bamboohr_id: ENV["PLANKBOT_REMIND_REMOTE_EXCEPT"].split(','))
        people.each do |x|
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: x.slack_id,
            text: message,
            as_user: true,
          )
        end
      else
        person = Plankbot::Reviewer.find_by(name: channel)

        if person
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: person.slack_id,
            text: message,
            as_user: true,
          )
        else
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: channel,
            text: message,
            as_user: true,
          )
        end
      end
    end
  end
end
