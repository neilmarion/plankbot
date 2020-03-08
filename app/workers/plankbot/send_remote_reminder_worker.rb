module Plankbot
  class SendRemoteReminderWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::SendRemoteReminder.execute
    end
  end
end
