require 'bamboozled'

module Plankbot
  class AnnounceBamboohrLeaves
    def execute
      date_now = (DateTime.now + 8.hours).to_date.to_s

      client = Bamboozled.client(subdomain: "firstcircle", api_key: ENV["BAMBOOHR_API_KEY"])

      eng_employees = Plankbot::Reviewer.where.not(bamboohr_id: nil).inject({}) do |hash, reviewer|
        team = reviewer.tags.where(kind: "team").first&.name

        hash[reviewer.bamboohr_id.to_i] = { name: reviewer.name, team: team }
        hash
      end

      engs_ooo = get_engs_ooo(eng_employees, date_now)

      return if engs_ooo.blank?

      announce(engs_ooo, date_now)
    end

    private

    def announce(engs_ooo, date_now)
      # NOTE: Announce to all

      slack_channels = JSON.parse(ENV["PLANKBOT_TEAM_TAG_SLACK_CHANNELS"])
      slack_channels.each do |k, channel|
        engs, heading = case k
        when "all"
          [engs_ooo, "*These are the engineers out of office today (#{date_now}):*"]
        else
          engs = engs_ooo.select{ |x| x[:team] == k }
          [engs, "*These are the engineers out of office today for this team (#{date_now}):*"]
        end

        next if engs.blank?

        begin
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: channel,
            text:  heading + "\n" + engs.map.with_index{|e, i| "#{icon(e[:type])} #{i+1}) #{e[:name]} _(#{e[:type]}#{e[:notes]})_" }.join("\n"),
            as_user: true,
          )
        rescue Slack::Web::Api::Errors::SlackError => e
        end
      end
    end

    def get_engs_ooo(eng_employees, date_now)
      result = HTTParty.get(
        "https://api.bamboohr.com/api/gateway.php/firstcircle/v1/time_off/requests/?start=#{date_now}&end=#{date_now}",
        basic_auth: { username: ENV["BAMBOOHR_API_KEY"], password: "x" },
        headers: { "Accept" => "application/json", "User-Agent" => "Bamboozled/0.2.0" },
      )

      employee_requests = JSON.parse(result.body)

      employee_requests.inject([]) do |array, request|
        if (eng_employees.keys.include? request["employeeId"].to_i) && (request["status"]["status"] != "canceled" && request["status"]["status"] != "denied")
          array << eng_employees[request["employeeId"].to_i].merge({type: request["type"]["name"], notes: notes(request) })
        end

        array
      end
    end

    def notes(request)
      return "" if request["notes"].blank?

      " - #{request["notes"]["employee"]}"
    end

    def icon(type)
      case type
      when "Remote"
        ":house:"
      when "Vacation"
        ":palm_tree:"
      when "Sick"
        ":facepalm:"
      when "Emergency"
        ":fire:"
      when "Bereavement"
        ":broken_heart:"
      when "Maternity Leave"
        ":pregnant_woman:"
      when "Paternity Leave"
        ":man:"
      else
        ":knife:"
      end
    end
  end
end
