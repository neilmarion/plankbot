module Plankbot
  class ReviewersController < ApplicationController
    before_action :destroy_tags, only: [:update]

    def show
      @reviewer = Reviewer.find(params[:id])
      @availability_tags = Tag.where(kind: "availability")
      @time_available_tags = Tag.where(kind: "time_available")
      @team_tags = Tag.where(kind: ["team", "tier"])
      @department_tags = Tag.where(kind: ["department"])
    end

    def update
      @reviewer = Reviewer.find(params[:id])
      @reviewer.update_attributes(reviewer_params)

      redirect_to pull_requests_path
    end

    private

    def reviewer_params
      params.require(:reviewer).
        permit(reviewer_tag_relationships_attributes: [:tag_id])
    end

    def destroy_tags
      @reviewer = Reviewer.find(params[:id])
      @reviewer.reviewer_tag_relationships.destroy_all
    end
  end
end
