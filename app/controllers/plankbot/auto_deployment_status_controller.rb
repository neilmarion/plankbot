module Plankbot
  class AutoDeploymentStatusController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: [:index, :toggle]

    def index
      render json: {
        status: Redis.new.get(Plankbot::ToggleAutoDeployment::AUTO_DEPLOY_REDIS_KEY)&.to_i,
      }
    end

    def toggle
      Plankbot::ToggleAutoDeployment.execute
    end
  end
end
