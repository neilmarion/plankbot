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
      reviewer = Plankbot::Reviewer.find_by(slack_id: data.user)
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

    command 'announce' do |client, data, match|
      begin
        exp = match["expression"]
        array = exp.split(" ")

        datetime_string = array.first
        person = array.second
        message = array[2..array.length-1].join(" ")

        Plankbot::AnnouncementWorker.perform_at(DateTime.parse(datetime_string) - 8.hours, person, message)
        client.say(channel: data.channel, text: "Message now queued")
      rescue Exception => e
        client.say(channel: data.channel, text: "Something went wrong")
      end
    end

    command 'in' do |client, data, match|
      begin
        note = match["expression"]

        result = Plankbot::TogglePresenceService.new({
          slack_id: data.user,
          status: "online",
          note: note,
          kind: "plankbot",
        }).execute

        if result == true
          client.say(channel: data.channel, text: "You have signed-in.\n_<Check your hours|https://plankbot.firstcircle.ph/attendances>. Please avoid overworking. Remember to always have balance in your life. :woman_in_lotus_position:_\n")
        else
          client.say(channel: data.channel, text: "You cannot sign-in again since you already are.")
        end
      rescue Exception => e
        client.say(channel: data.channel, text: "Something went wrong")
      end
    end

    command 'out' do |client, data, match|
      begin
        note = match["expression"]

        result = Plankbot::TogglePresenceService.new({
          slack_id: data.user,
          status: "offline",
          note: note,
          kind: "plankbot",
        }).execute

        employee = Plankbot::Reviewer.find_by(slack_id: data.user)
        total_time_in_today = employee.total_time_in_today_readable(Time.current)

        if result == true
          client.say(channel: data.channel, text: "You have signed-out.\n_Total time in today is #{total_time_in_today}._")
        else
          client.say(channel: data.channel, text: "You cannot sign-out again since you already are.")
        end
      rescue Exception => e
        client.say(channel: data.channel, text: "Something went wrong")
      end
    end

    command 'help' do |client, data, match|
      text = "- `redeploy (fca|fcc) (prod|preprod)` to redeploy Cloud66 instance\n" +
      text = "- `showenvs` to show stack environments\n" +
      text = "- `myprs` to show current PRs\n"

      client.say(channel: data.channel, text: text)
    end
  end
end
