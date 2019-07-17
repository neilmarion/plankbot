module Plankbot
  class TransformReleases
    TEAMS = {
      10103 => "CJE",
      10105 => "ORIG",
      10104 => "UP",
      10113 => "PFM",
    }

    def self.execute(extracted_releases)
      extracted_releases.map do |release|
        next if Release.where(jira_id: release["id"]).exists? || !release["released"]

        release["team"] = TEAMS[release["projectId"]]
        next unless release["team"]

        result = HTTParty.post(
          "https://firstcircle.atlassian.net/rest/api/3/search",
          headers: {
            "Authorization" => "Basic #{ENV["PLANKBOT_JIRA_BASIC_AUTH_TOKEN"]}",
            "Accept" => "application/json",
            "Content-Type" => "application/json",
          },
          body: {
            expand: [
              "names",
              "schema",
              "operations"
            ],
            jql: "fixVersion = \"#{release["name"]}\"",
            maxResults: 100,
            fieldsByKeys: false,
            fields: [
              "summary",
              "status",
              "assignee",
              "issuetype",
              "project",
              "sprint",
              "reporter",
            ],
            startAt: 0
          }.to_json,
        )

        release["issues"] = result["issues"].map do |issue|
          {
            summary: issue["fields"]["summary"],
            key: issue["key"],
            jira_id: issue["id"],
            issue_type: issue["fields"]["issuetype"]["name"],
          }
        end

        next if release["issues"].blank?

        release
      end.compact
    end
  end
end
