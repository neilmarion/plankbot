class RemindReviewers
  def self.execute
    unapproved_pull_requests = Plankbot::PullRequest.unapproved
    unapproved_pull_requests.map(&:ping_reviewers)
  end
end
