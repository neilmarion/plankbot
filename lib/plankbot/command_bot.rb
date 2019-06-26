module Plankbot
  class CommandBot < Plankbot::Bot
    command 'redeploy' do |client, data, match|
      exp = match["expression"]
      length = exp.split(" ").last.to_i
      stack_id = if /^fca prod$/ === exp
        ENV['PLANKBOT_FCA_PROD_STACK_ID']
      elsif /^fca preprod$/ === exp
        ENV['PLANKBOT_FCA_PREPROD_STACK_ID']
      elsif /^fcc prod$/ === exp
        ENV['PLANKBOT_FCC_PROD_STACK_ID']
      elsif /^fcc preprod$/ === exp
        ENV['PLANKBOT_FCC_PREPROD_STACK_ID']
      end

      unless stack_id
        client.say(channel: data.channel, text: "Invalid command")
        return
      end

      HTTParty.post("https://app.cloud66.com/api/3/stacks/#{stack_id}/deployments",
        :body => {},
        :headers => { "Authorization" => "Bearer #{ENV['PLANKBOT_CLOUD66_AUTH_CODE']}" }
      )

      client.say(channel: data.channel, text: "Redeploying...")
    end

    command 'help' do |client, data, match|
      text = "- `redeploy (fca|fcc) (prod|preprod)` to redeploy Cloud66 instance\n"

      client.say(channel: data.channel, text: text)
    end
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
