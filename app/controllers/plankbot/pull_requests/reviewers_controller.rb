module Plankbot
  module PullRequests
    class ReviewersController < ActionController::Base
      def remove_reviewer
        PullRequest.find_by_id(params[:pull_request_id]).
          pull_request_reviewer_relationships.
          find_by_reviewer_id(Reviewer.find(params[:id])).destroy

        redirect_to edit_pull_request_path(params[:pull_request_id])
      end

      def add_reviewer
        PullRequest.find_by_id(params[:pull_request_id]).
          pull_request_reviewer_relationships.
          create(reviewer_id: params[:id])

        redirect_to edit_pull_request_path(params[:pull_request_id])
      end
    end
  end
end
