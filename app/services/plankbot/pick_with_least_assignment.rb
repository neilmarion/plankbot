module Plankbot
  class PickWithLeastAssignment
    REVIEW_READY_LABEL = "review_ready"
    RELEASE_LABEL = "release"

    def self.execute(context)
      reviewer_count =
        if context[:pull_request].labels.
          where(name: REVIEW_READY_LABEL).exists?
          2
        elsif context[:pull_request].labels.
          where(name: RELEASE_LABEL).exists?
          1
        end

      # NOTE: If labels does not exist
      unless reviewer_count
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
