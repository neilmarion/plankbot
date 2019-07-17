module Plankbot
  class ExtractCriticalIssues
    def self.execute
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
          jql: "labels in (critical) AND status != done AND project IN (CJE, UP, ORIG, PFM)",
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
            "description",
          ],
          startAt: 0
        }.to_json,
      )

      result.parsed_response["issues"]
    end
  end
end
