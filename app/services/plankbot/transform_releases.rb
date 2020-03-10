module Plankbot
  class TransformReleases
    def self.execute(extracted_releases)
      extracted_releases.map do |release|
        next if Release.where(jira_id: release["id"]).exists?

        result = HTTParty.get(
          "https://www.pivotaltracker.com/services/v5/projects/#{release["project_id"]}/stories/#{release["id"]}/blockers",
          headers: {
            "X-TrackerToken" => ENV["PLANKBOT_PT_API_SECRET"],
          },
        )

        teams = JSON.parse(ENV["PLANKBOT_PT_PROJECT_IDS"])
        blockers = JSON.parse(result.body)
        release["team"] = teams[release["project_id"].to_s]
        release["issues"] = blockers.map do |blocker|
          story_id = blocker["description"].scan(/\d/).join

          result = HTTParty.get(
            "https://www.pivotaltracker.com/services/v5/projects/#{release["project_id"]}/stories/#{story_id}",
            headers: {
              "X-TrackerToken" => ENV["PLANKBOT_PT_API_SECRET"],
            },
          )

          issue = JSON.parse(result.body)

          {
            summary: issue["name"],
            jira_id: issue["id"],
            issue_type: issue["story_type"],
            key: issue["id"],
            current_state: issue["current_state"],
          }
        end

        next if release["issues"].blank?

        release
      end.compact
    end
  end
end
