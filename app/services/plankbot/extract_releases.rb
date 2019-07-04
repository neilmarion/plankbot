module Plankbot
  class ExtractReleases
    TEAMS = ["CJE", "ORIG", "UP"]

    def self.execute
      releases = []

      TEAMS.each do |team|
        releases = releases + HTTParty.get(
          "https://firstcircle.atlassian.net/rest/api/3/project/#{team}/versions",
          headers: {
            "Authorization" => "Basic #{ENV["PLANKBOT_JIRA_BASIC_AUTH_TOKEN"]}"
          },
        )
      end

      releases
    end
  end
end
