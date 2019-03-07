module Plankbot
  class PullRequestLabelRelationship < ApplicationRecord
    belongs_to :pull_request
    belongs_to :label
  end
end
