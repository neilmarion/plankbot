module Plankbot
  module CodeReview
    class InitializeReviewerCount
      REVIEW_READY_LABEL = "review_ready"
      RELEASE_LABEL = "release"
      ENGINEERING_DEPARTMENT_LABEL = "engineering"
      DATA_DEPARTMENT_LABEL = "data"

      def self.execute(context)
        context[:reviewer_count] =
          if context[:pull_request].labels.
            where(name: REVIEW_READY_LABEL).exists? &&
            context[:pull_request].labels.
            where(name: ENGINEERING_DEPARTMENT_LABEL).exists?
            2
          elsif context[:pull_request].labels.
            where(name: RELEASE_LABEL).exists?
            1
          else
            1
          end

        context
      end
    end
  end
end
