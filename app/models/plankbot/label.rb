# NOTE: Hierarchy
# A. "review_ready" - will look for 2 reviewers
#    "release" - will look for 1 reviewers
# B. "onboarding" - will look for all reviewers with tag == "onboarding"
#    "min" - will look for all reviewers with tag == "min"
#    "mout" - will look for all reviewers with tag == "mout"
#    "prodeng" - will look for all reviewers with tag == "prodeng"

module Plankbot
  class Label < ApplicationRecord
    TRIGGER_LABELS = ["review_ready", "release"]
    TEAM_LABELS = ["onboarding", "min", "mout", "prodeng"]
    HIGH_SENSITIVITY_LABELS = ["high_sensitivity"]

    has_many :pull_requests
  end
end
