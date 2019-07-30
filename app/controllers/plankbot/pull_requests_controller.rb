module Plankbot
  class PullRequestsController < ApplicationController
    def index
      if params[:department].blank?
        @unapproved_prs = PullRequest.unapproved
        @approved_prs = PullRequest.
          approved.
          where(
            created_at: Time.current.beginning_of_day..Time.current.end_of_day
          )

        @prs = (@unapproved_prs.to_a + @approved_prs.to_a).uniq
        @reviewers = Reviewer.all
      else
        @unapproved_prs = Label.find_by_name(params[:department]).pull_requests.unapproved
        @approved_prs = Label.find_by_name(params[:department]).pull_requests.
          approved.
          where(
            created_at: Time.current.beginning_of_day..Time.current.end_of_day
          )

        @prs = (@unapproved_prs.to_a + @approved_prs.to_a).uniq

        @reviewers = Tag.find_by(name: params[:department], kind: "department").reviewers
      end
    end

    def edit
      @pull_request = PullRequest.find_by_id(params[:id])
      @reviewers = Reviewer.all
    end
  end
end
