module Plankbot
  class ApprovePullRequest
    TEAM_LABELS = ["onboarding", "min", "mout", "prodeng"]

    def self.execute(pull_request:, approvers:)
      approvers.each do |approver|
        reviewer = Plankbot::Reviewer.find_by_github_id(approver)
        next unless reviewer
        # NOTE: Do not include the requestor as an approver
        # if they set a :+1: comment in their own PR
        next if pull_request.requestor.id == reviewer.id

        rel = pull_request.
          pull_request_reviewer_relationships.
          find_or_create_by(reviewer: reviewer)

        next if rel.approved_at

        rel.update_attributes(approved_at: DateTime.current)
      end
    end
  end
end
