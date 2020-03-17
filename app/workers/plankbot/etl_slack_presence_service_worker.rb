module Plankbot
  class EtlSlackPresenceServiceWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlSlackPresenceService.new.execute
    end
  end
end
