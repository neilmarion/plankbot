module Plankbot
  class FilterByAvailability
    YES_TAG = "Yes"
    NO_TAG = "No"

    def self.execute(context)
      context[:remaining].reject! do |x|
        x.tags.where(kind: "availability").pluck(:name).include? NO_TAG
      end

      context
    end
  end
end
