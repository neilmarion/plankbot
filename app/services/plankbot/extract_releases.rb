module Plankbot
  class ExtractReleases
    def self.execute
      releases = []

      project_ids = JSON.parse(ENV["PLANKBOT_PT_PROJECT_IDS"])

      project_ids.keys.each do |project_id|
        result = HTTParty.get(
          "https://www.pivotaltracker.com/services/v5/projects/#{project_id}/releases?with_state=accepted",
          headers: {
            "X-TrackerToken" => ENV["PLANKBOT_PT_API_SECRET"],
          },
        )
        releases = releases + JSON.parse(result.body)
      end

      releases.flatten
    end
  end
end
