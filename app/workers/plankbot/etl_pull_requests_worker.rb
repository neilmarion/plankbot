module Plankbot
  class EtlPullRequestsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      CodeReview::EtlPullRequests.execute
    end
  end
end
