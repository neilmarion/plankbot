module Plankbot
  class TestRunsController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: [:run, :status]

    def index
      @test_runs = TestRun.all.order(created_at: :desc)
    end

    def show
      @test_run = TestRun.find(params[:id])
    end

    def status
      test_run = TestRun.find_by(
        github_repo_id: params[:github_repo_id],
        circle_build_id: params[:circle_build_id],
      )

      if test_run
        render json: {
          status: test_run.status,
        }
      else
        render json: {
          error: "SOMETHING WENT WRONG",
        }, status: :internal_server_error
      end
    end

    def cancel
      test_run = TestRun.find(id: params[:id])
      test_run.cancel
    end

    def run
      if TestRun.create(test_run_params)
      else
        render json: {
          error: "SOMETHING WENT WRONG",
        }, status: :internal_server_error
      end
    end

    private

    def test_run_params
      params.require(:test_run).
        permit(
          :github_username,
          :github_org,
          :github_repo,
          :github_branch,
          :github_repo_id,
          :circle_build_id,
          :github_commit_hash,
        )
    end
  end
end
