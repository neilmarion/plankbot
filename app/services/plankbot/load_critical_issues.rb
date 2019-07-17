module Plankbot
  class LoadCriticalIssues
    def self.execute(transformed_critical_issues)

      transformed_critical_issues.each do |transformed_critical_issue|
        issue = CriticalIssue.create({
          summary: transformed_critical_issue[:summary] || "",
          key: transformed_critical_issue[:key] || "",
          jira_id: transformed_critical_issue[:jira_id] || "",
          issue_type: transformed_critical_issue[:issue_type] || "",
          reporter: transformed_critical_issue[:reporter] || "",
        })

        issue.reload
        issue.announce
      end
    end
  end
end
