module Plankbot
  class EtlPullRequestsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::EtlPullRequests.execute
    end
  end
end
