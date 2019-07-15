module Plankbot
  class SendDailyStatsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::SendDailyStats.execute
    end
  end
end
