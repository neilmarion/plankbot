module Plankbot
  class EtlCriticalIssuesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlCriticalIssues.execute
    end
  end
end
