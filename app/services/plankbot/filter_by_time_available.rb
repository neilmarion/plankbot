module Plankbot
  class FilterByTimeAvailable
    TAGS_AND_RANGES = [
      {tag: "06:00-15:00", from: "06:00", to: "15:00"},
      {tag: "07:00-16:00", from: "07:00", to: "16:00"},
      {tag: "08:00-17:00", from: "08:00", to: "17:00"},
      {tag: "09:00-18:00", from: "09:00", to: "18:00"},
    ]

    def self.execute(context)
      selected_tags = TAGS_AND_RANGES.select do |x|
        # NOTE: Refactor so that we can remove 'in_time_zone'
        Time.current >= Time.parse(x[:from] + " +08:00") &&
          Time.current < Time.parse(x[:to] + " +08:00")
      end.map{ |x| x[:tag] }

      context[:remaining].reject! do |x|
        (x.tags.where(kind: "time_available").
         pluck(:name) & selected_tags).blank?
      end

      context
    end
  end
end
