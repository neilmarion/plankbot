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

    command 'showenvs' do |client, data, match|
      text = JSON.parse(ENV['PLANKBOT_FC_ENVIRONMENTS']).map.with_index do |t, i|
        "*#{i+1}) #{t["desc"]}:* <#{t["fcc"]["url"]}|fcc> _#{t["fcc"]["branch"]}_ <#{t["fcc"]["infra"]}|infra>, <#{t["fca"]["url"]}|fca> _#{t["fca"]["branch"]}_ <#{t["fca"]["infra"]}|infra>, <#{t["site"]["url"]}|site> _#{t["site"]["branch"]}_ <#{t["site"]["infra"]}|infra>"
      end

      note = "_* Ping <@U4SK3RBPS> if there are changes in ownership of an environment_"

      client.say(channel: data.channel, text: text.join("\n") + "\n" + note)
    end

    command 'help' do |client, data, match|
      text = "- `redeploy (fca|fcc) (prod|preprod)` to redeploy Cloud66 instance\n" +
      text = "- `showenvs` to show stack environments\n"

      client.say(channel: data.channel, text: text)
    end
  end
end

if Rails.env.production?
  Thread.abort_on_exception = true
  Thread.new do
    begin
      Plankbot::CommandBot.run
    rescue Slack::Web::Api::Errors::SlackError
      raise("Invalid ENV['PLANKBOT_SLACK_API_TOKEN']")
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
