module Plankbot
  class PickWithLeastAssignment
    REVIEW_READY_LABEL = "review_ready"
    RELEASE_LABEL = "release"

    def self.execute(context)
      reviewer_count = context[:reviewer_count]
      # NOTE: If labels does not exist
      if reviewer_count == 0
        context[:chosen] = []
        return context
      end

      if context[:chosen].count > reviewer_count
        new_chosen =
          context[:chosen][0...-(context[:chosen].count - reviewer_count)]
        discard = context[:chosen] - new_chosen
        context[:pull_request].
          pull_request_reviewer_relationships.
          where(reviewer_id: discard.map(&:id), approved_at: nil).
          destroy_all

        context[:chosen] = new_chosen
      elsif context[:chosen].count < reviewer_count
        remaining_count = reviewer_count - context[:chosen].count
        context[:chosen] = context[:chosen] +
          context[:remaining][0...(remaining_count)]
      end

      context
    end
  end
end
