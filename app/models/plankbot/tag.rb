# NOTE: Hierarchy
# A. "availability"
# B. "time_available"
# C. "team"

module Plankbot
  class Tag < ApplicationRecord
    has_many :reviewer_tag_relationships
    has_many :reviewers, through: :reviewer_tag_relationships
  end
end
