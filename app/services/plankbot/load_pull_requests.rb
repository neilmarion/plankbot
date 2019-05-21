module Plankbot
  class LoadPullRequests
    def self.execute(transformed_pull_requests)
      pr_github_ids = transformed_pull_requests.map{ |x| x[:github_id] }
      destroy_non_labeled_unapproved_pull_requests(pr_github_ids)

      pull_requests = transformed_pull_requests.each do |pr|
        requestor = Plankbot::Reviewer.
          find_by_github_id(pr[:requestor_github_id])

        next if requestor.blank?

        pull_request = Plankbot::PullRequest.find_by(
          github_id: pr[:github_id],
        )

        # NOTE: Create PRs
        unless pull_request
          pull_request = Plankbot::PullRequest.create(
            title: pr[:title],
            url: pr[:url],
            github_id: pr[:github_id],
            requestor: requestor,
          )
        end

        # NOTE: Associate labels
        pr[:labels].each do |name|
          label = Plankbot::Label.find_by_name(name)
          next if label.blank?
          next if pull_request.labels.find_by(name: name).present?

          pull_request.pull_request_label_relationships.create(label: label)
        end

        ApprovePullRequest.execute({
          pull_request: pull_request,
          approvers: pr[:approvers],
        })

        chosen_reviewers =
          PickReviewers.execute(pull_request: pull_request)

        chosen_reviewers.each do |reviewer|
          next if pull_request.
            reviewers.find_by(id: reviewer.id).present?

          pull_request.pull_request_reviewer_relationships.
            create(reviewer: reviewer)
        end
      end
    end

    private

    def self.destroy_non_labeled_unapproved_pull_requests(pr_github_ids)
      to_be_destroyed_prs = Plankbot::PullRequest.unapproved.to_a
      to_be_destroyed_prs.reject!{ |x| pr_github_ids.include? x.github_id }
      to_be_destroyed_prs.map(&:destroy_with_ping)
    end
  end
end
