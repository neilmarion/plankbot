module Plankbot
  class ReleaseIssue < ApplicationRecord
    belongs_to :release
  end
end
