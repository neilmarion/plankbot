module Plankbot
  class EtlSlackPresenceService
    def execute
      people = Plankbot::Reviewer.where.not(bamboohr_id: nil)

      people.each do |person|
        result = HTTParty.post("https://slack.com/api/users.getPresence", {
          body: {
            token: ENV['PLANKBOT_SLACK_API_TOKEN'],
            user: person.slack_id,
          },
        })

        result = JSON.parse(result.body)

        presence = result["presence"]
        next if presence == nil

        Plankbot::TogglePresenceService.new({
          slack_id: person.slack_id,
          status: presence == "active" ? "online" : "offline",
          note: nil,
          kind: "slack",
        }).execute
      end
    end
  end
end
