module Plankbot
  class AutoDeploymentStatusController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: [:index]

    def index
      render json: {
        status: ENV["PLANKBOT_FREEZE_DEPLOYMENTS"]&.to_i,
      }
    end
  end
end
