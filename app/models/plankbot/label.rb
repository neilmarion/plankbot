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
    TEAM_LABELS = ["cje", "up", "orig", "platform"]
    HIGH_SENSITIVITY_LABELS = ["high_sensitivity"]
    CODE_QUALITY_LABELS = ["fcc_code_quality_check", "fca_code_quality_check"]

    COLORS = {
      "review_ready" => "#2ecc71",
      "release" => "#1abc9c",
      "high_sensitivity" => "#c0392b",
      "fcc" => "#673AB7",
      "fca" => "#9C27B0",
      "fca_code_quality_check" => "#E91E63",
      "fcc_code_quality_check" => "#F44336",
      "cje" => "#3498db",
      "up" => "#e67e22",
      "orig" => "#f1c40f",
      "data" => "#2196F3",
      "engineering" => "#8BC34A",
      "data-airflow" => "#fd79a8",
      "data-warehouse" => "#e17055",
      "limits-engine" => "#6D214F",
    }

    has_many :pull_request_label_relationships
    has_many :pull_requests, through: :pull_request_label_relationships
  end
end
