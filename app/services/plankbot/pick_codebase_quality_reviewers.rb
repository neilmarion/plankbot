module Plankbot
  class PickCodebaseQualityReviewers
    FCC_QUALITY_CHECK = "fcc_code_quality_check"
    FCA_QUALITY_CHECK = "fca_code_quality_check"

    def self.execute(context)
      fcc_tag = Tag.find_by({
        name: FCC_QUALITY_CHECK,
        kind: "tier",
      })

      fca_tag = Tag.find_by({
        name: FCA_QUALITY_CHECK,
        kind: "tier",
      })

      return context if fcc_tag.blank? && fca_tag.blank?

      fcc_quality_label = context[:pull_request].labels.where({
        name: fcc_tag.name,
      }).exists?

      fca_quality_label = context[:pull_request].labels.where({
        name: fca_tag.name,
      }).exists?

      return context if fcc_quality_label && fca_quality_label

      requestor = context[:pull_request].requestor
      fcc_chosen = fcc_tag.reviewers.where.not(id: requestor&.id)
      fca_chosen = fca_tag.reviewers.where.not(id: requestor&.id)

      if fcc_quality_label
        context[:chosen] = fcc_chosen.to_a + context[:chosen]
      elsif fca_quality_label
        context[:chosen] = fca_chosen.to_a + context[:chosen]
      end

      context
    end
  end
end
