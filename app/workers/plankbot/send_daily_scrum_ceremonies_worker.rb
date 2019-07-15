module Plankbot
  class SendDailyScrumCeremoniesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::SendDailyScrumCeremonies.execute
    end
  end
end
