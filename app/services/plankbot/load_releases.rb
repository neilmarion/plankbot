module Plankbot
  class LoadReleases
    def self.execute(transformed_releases)
      transformed_releases.each do |transformed_release|
        release = Release.create({
          name: transformed_release["name"],
          team: transformed_release["team"],
          jira_id: transformed_release["id"],
          description: transformed_release["name"] || "",
          start_date: transformed_release["created_at"],
          release_date: transformed_release["accepted_at"],
        })

        transformed_release["issues"].each do |issue|
          next unless issue[:current_state] == "accepted"
          release.release_issues.create(
            summary: issue[:summary] || "",
            jira_id: issue[:jira_id] || "",
            issue_type: issue[:issue_type] || "",
            key: issue[:key] || "",
          )
        end

        release.reload
        release.announce
      end
    end
  end
end
