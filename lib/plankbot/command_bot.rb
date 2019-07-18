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

      result = HTTParty.get("https://app.cloud66.com/api/3/stacks/#{stack_id}",
        :headers => { "Authorization" => "Bearer #{ENV['PLANKBOT_CLOUD66_AUTH_CODE']}" }
      )

      return if result.parsed_response["response"]["is_busy"]

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

    command 'myprs' do |client, data, match|
      reviewer = Reviewer.find_by(slack_id: data.user)
      pull_requests = Plankbot::PullRequest.
        unapproved.where(requestor_id: reviewer.id)

      text = pull_requests.map do |pull_request|
        approved_reviewers_text = pull_request.approved_reviewers.map do |ar|
          "#{ar.name} ✔"
        end

        unapproved_reviewers_text = pull_request.unapproved_reviewers.map do |ur|
          "#{ur.name} —"
        end

        "- <#{pull_request.url}|#{pull_request.title}> - #{(approved_reviewers_text + unapproved_reviewers_text).join(', ')}"
      end

      text = text.blank? ? "You got no unapproved PRs" : text.join("\n")

      client.say(channel: data.channel, text: text)
    end

    command 'help' do |client, data, match|
      text = "- `redeploy (fca|fcc) (prod|preprod)` to redeploy Cloud66 instance\n" +
      text = "- `showenvs` to show stack environments\n" +
      text = "- `myprs` to show current PRs\n"

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
