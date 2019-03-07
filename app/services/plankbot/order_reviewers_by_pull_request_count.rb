module Plankbot
  class OrderReviewersByPullRequestCount
    def self.execute(context)
      remaining = Plankbot::Reviewer.all.
        sort_by{ |reviewer| reviewer.pull_request_count }
      context[:remaining] = remaining

      context
    end
  end
end
