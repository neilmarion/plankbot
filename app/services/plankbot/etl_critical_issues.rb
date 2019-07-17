module Plankbot
  class EtlCriticalIssues
    def self.execute
      extracted_critical_issues = ExtractCriticalIssues.execute
      transformed_critical_issues = TransformCriticalIssues.execute(extracted_critical_issues)
      LoadCriticalIssues.execute(transformed_critical_issues)
    end
  end
end
