module Plankbot
  class Attendance < ApplicationRecord
    belongs_to :requestor, {
      foreign_key: :requestor_id,
      class_name: "Reviewer",
    }
  end
end
