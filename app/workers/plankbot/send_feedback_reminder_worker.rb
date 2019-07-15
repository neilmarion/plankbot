module Plankbot
  class SendFeedbackReminderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::SendFeedbackReminder.execute
    end
  end
end
