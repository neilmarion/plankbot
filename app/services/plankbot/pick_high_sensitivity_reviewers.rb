module Plankbot
  class PickHighSensitivityReviewers
    HIGH_SENSITIVITY = "high_sensitivity"

    def self.execute(context)
      tag = Tag.find_by({
        name: HIGH_SENSITIVITY,
        kind: "tier",
      })

      return context unless tag

      highly_sensitive = context[:pull_request].labels.where({
        name: tag.name,
      }).exists?

      return context unless highly_sensitive

      requestor = context[:pull_request].requestor
      chosen = tag.reviewers.where.not(id: requestor&.id)

      context[:chosen] = chosen.to_a + context[:chosen]
      context
    end
  end
end
