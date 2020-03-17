module Plankbot
  class EtlAndAnnounceBamboohrAttendancesStart
    def execute
      attendance_ids = EtlBamboohrAttendances.new.execute
      announce(attendance_ids)
    end

    private

    def announce(attendance_ids)
      # NOTE: Announce to all
      date_now = (DateTime.now + 8.hours).to_date.to_s

      slack_channels = JSON.parse(ENV["PLANKBOT_TEAM_TAG_SLACK_CHANNELS"])

      attendances = Plankbot::Attendance.where(id: attendance_ids)
      slack_channels.each do |k, channel|
        selected, heading = case k
        when "all"
          [attendances, "*These are the people out of office today (#{date_now}):* <#{ENV["PLANKBOT_HOST"]}/attendances?date=#{date_now}|details>"]
        else
          s = attendances.select do |attendance|
            attendance.requestor.tags.where(kind: "team").exists?(name: k)
          end

          [s, "*These are the people out of office today for this team (#{date_now}):* <#{ENV["PLANKBOT_HOST"]}/attendances?date=#{date_now}|details>"]
        end

        next if selected.blank?

        begin
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: channel,
            text:  heading + "\n" + selected.map.with_index{|a, i| "#{icon(a.kind)} #{i+1}) <#{ENV["PLANKBOT_HOST"]}/reviewers/#{a.requestor.id}/attendances|#{a.requestor.name}> _(#{a.kind} - #{a.note})_" }.join("\n"),
            as_user: true,
          )
        rescue Slack::Web::Api::Errors::SlackError => e
        end
      end
    end

    private

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
