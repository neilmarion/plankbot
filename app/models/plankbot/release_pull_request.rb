module Plankbot
  class ReleasePullRequest < ApplicationRecord
    belongs_to :release
  end
end
