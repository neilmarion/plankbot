module Plankbot
  class TransformReleases
    def self.execute(extracted_releases)
      extracted_releases.map do |release|
        next if Release.where(jira_id: release["id"]).exists?

        result = HTTParty.get(
          "https://www.pivotaltracker.com/services/v5/projects/#{release["project_id"]}/releases/#{release["id"]}/stories",
          headers: {
            "X-TrackerToken" => ENV["PLANKBOT_PT_API_SECRET"],
          },
        )

        teams = JSON.parse(ENV["PLANKBOT_PT_PROJECT_IDS"])

        issues = JSON.parse(result.body)
        release["team"] = teams[release["project_id"].to_s]
        release["issues"] = issues.map do |issue|
          {
            summary: issue["name"],
            jira_id: issue["id"],
            issue_type: issue["story_type"],
            key: issue["id"],
          }
        end

        next if release["issues"].blank?

        release
      end.compact
    end
  end
end
