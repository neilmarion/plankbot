module Plankbot
  class SendWeeklyReleaseNotesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      SendWeeklyReleaseNotes.execute
    end
  end
end
