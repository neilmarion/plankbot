module Plankbot
  class RemindReviewers
    def self.execute
      return if Plankbot::Setting.is_shutdown?

      unapproved_pull_requests = Plankbot::PullRequest.unapproved
      unapproved_pull_requests.map(&:ping_reviewers)
    end
  end
end
