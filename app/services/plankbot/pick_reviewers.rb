module Plankbot
  class PickReviewers
    def self.execute(pull_request:)
      context = {
        chosen: [],
        remaining: [],
        pull_request: pull_request,
        reviewer_count: 0,
      }

      context = InitializeReviewerCount.execute(context)
      context = OrderReviewersByPullRequestCount.execute(context)
      context = RemoveRequestor.execute(context)
      context = RemoveAssigned.execute(context)
      context = FilterByAvailability.execute(context)
      context = FilterByTimeAvailable.execute(context)
      context = PickCodebaseQualityReviewers.execute(context)
      context = PickHighSensitivityReviewers.execute(context)
      context = PickTeammate.execute(context)
      context = PickWithLeastAssignment.execute(context)

      context[:chosen]
    end
  end
end
