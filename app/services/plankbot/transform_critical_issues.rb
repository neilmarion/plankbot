module Plankbot
  class TransformCriticalIssues
    def self.execute(extracted_critical_issues)
      return [] if extracted_critical_issues.blank?

      transformed_critical_issues = extracted_critical_issues.map do |issue|
        next if CriticalIssue.where(jira_id: issue["id"]).exists?

        {
          summary: issue["fields"]["summary"],
          key: issue["key"],
          jira_id: issue["id"],
          issue_type: issue["fields"]["issuetype"]["name"],
          reporter: issue["fields"]["reporter"]["displayName"],
        }
      end.compact

      transformed_critical_issues
    end
  end
end
