module Plankbot
  class EtlReleasesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlReleases.execute
    end
  end
end
