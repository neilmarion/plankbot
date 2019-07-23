module Plankbot
  class ReviewerTagRelationship < ApplicationRecord
    belongs_to :reviewer
    belongs_to :tag

    after_create :remove_assignments

    private

    def remove_assignments
      if self.tag.kind == "availability" &&
          self.tag.name == CodeReview::FilterByAvailability::NO_TAG

        self.reviewer.
          pull_request_reviewer_relationships.
          unapproved.
          destroy_all
      end
    end
  end
end
