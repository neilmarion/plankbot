module Plankbot
  module CodeReview
    class PickCodebaseQualityReviewers
      def self.execute(context)
        tags = Tag.where({
          name: Plankbot::Label::CODE_QUALITY_LABELS,
          kind: "tier",
        })

        return context if tags.blank?

        requested = context[:pull_request].labels.where({
          name: Plankbot::Label::CODE_QUALITY_LABELS,
        }).exists?

        return context unless requested

        requestor = context[:pull_request].requestor

        context[:pull_request].labels.where(name: Plankbot::Label::Plankbot::Label::CODE_QUALITY_LABELS).each do |l|
          next if tags.find_by_name(l.name).reviewers.blank?

          chosen = tags.find_by_name(l.name).reviewers.
            where.not(id: requestor&.id)
          context[:chosen] = chosen.to_a + context[:chosen]
          context[:reviewer_count] = context[:reviewer_count] + chosen.to_a.count
        end

        context
      end
    end
  end
end
