module Plankbot
  class SlackController < ApplicationController
    skip_before_filter :verify_authenticity_token, only: [:get, :create]

    def show
      if params[:ref] == "github_id"
        reviewer = Reviewer.find_by(github_id: params[:id])

        if params[:formatted]
          render json: {
            value: "<@#{reviewer&.slack_id}>",
          }
        else
          render json: {
            value: reviewer&.slack_id,
          }
        end
      else
        render json: {
          value: nil,
        }
      end
    end

    def create
      begin
        reviewer = Reviewer.find_by(github_id: params[:github_id])

        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: reviewer.slack_id,
          text: params[:text],
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
