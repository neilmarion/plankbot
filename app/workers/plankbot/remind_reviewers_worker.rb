module Plankbot
  class RemindReviewersWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      CodeReview::RemindReviewers.execute
    end
  end
end
