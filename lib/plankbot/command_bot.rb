module Plankbot
  class CommandBot < Plankbot::Bot

  end
end

# NOTE: Only run the bot on a running server, not CLI
if Rails.const_defined?('Server') && !Rails.env.production?
  Thread.abort_on_exception = true
  Thread.new do
    begin
      Plankbot::CommandBot.run
    rescue Slack::Web::Api::Errors::SlackError
      raise("Invalid ENV['PLANKBOT_SLACK_API_TOKEN']")
    end
  end
end
