module Plankbot
  class SendFeedbackReminder
    FEEDBACK_URL = "https://form.asana.com/?hash=fd2d76933072c681e910839e17ccfb6d80cdef6ef0f028d402ded1db23165c79&id=1112819069424111"
    GUIDELINES_URL = "https://www.notion.so/techhub/Engineer-Peer-Feedback-4781e3dd8cb645ce96df416fb006b6c9"

    def self.execute
      people = JSON.parse(ENV["PLANKBOT_FEEDBACK_PEOPLE"])
      people.each do |x|
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: x["slack_id"],
          text: "#{x["name"]}, do you have a feedback to one of the engineers (Data/QA/Engineering)? Just fill up the form <#{FEEDBACK_URL}|here>. These are the <#{GUIDELINES_URL}|guidelines>.",
          as_user: true,
        )
      end
    end
  end
end
