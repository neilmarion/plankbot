module Plankbot
  class EtlAndAnnounceBamboohrAttendancesStartWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlAndAnnounceBamboohrAttendancesStart.new.execute
    end
  end
end
