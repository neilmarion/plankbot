module Plankbot
  class LoadReleases
    def self.execute(transformed_releases)

      transformed_releases.each do |transformed_release|
        release = Release.create({
          name: transformed_release["name"],
          team: transformed_release["team"],
          jira_id: transformed_release["id"],
          description: transformed_release["description"] || "",
          start_date: transformed_release["startDate"],
          release_date: transformed_release["releaseDate"],
        })

        transformed_release["issues"].each do |issue|
          release.release_issues.create(
            summary: issue[:summary] || "",
            key: issue[:key] || "",
            jira_id: issue[:jira_id] || "",
            issue_type: issue[:issue_type] || "",
          )
        end

        release.reload
        release.announce
      end
    end
  end
end
