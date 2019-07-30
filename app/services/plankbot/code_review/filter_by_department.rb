module Plankbot
  module CodeReview
    class FilterByDepartment
      def self.execute(context)
        context[:remaining] = if context[:pull_request].labels.
          where(name: InitializeReviewerCount::DATA_DEPARTMENT_LABEL).exists?

          Plankbot::Tag.
            find_by({
            name: InitializeReviewerCount::DATA_DEPARTMENT_LABEL,
            kind: "department",
          }).reviewers
        else
          Plankbot::Tag.
            find_by({
            name: InitializeReviewerCount::ENGINEERING_DEPARTMENT_LABEL,
            kind: "department",
          }).reviewers
        end

        context
      end
    end
  end
end
