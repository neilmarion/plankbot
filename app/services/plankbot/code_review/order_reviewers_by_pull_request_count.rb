module Plankbot
  module CodeReview
    class OrderReviewersByPullRequestCount
      def self.execute(context)
        context[:remaining] = context[:remaining].
          sort_by{ |reviewer| reviewer.pull_request_count_for_the_day }

        context
      end
    end
  end
end
