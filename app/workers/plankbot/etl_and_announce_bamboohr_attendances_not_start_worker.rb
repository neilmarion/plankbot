module Plankbot
  class EtlAndAnnounceBamboohrAttendancesNotStartWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlAndAnnounceBamboohrAttendancesNotStart.new.execute
    end
  end
end
