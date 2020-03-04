module Plankbot
  class AnnounceBamboohrLeavesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::AnnounceBamboohrLeaves.new.execute
    end
  end
end
