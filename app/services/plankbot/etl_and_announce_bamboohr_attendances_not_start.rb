module Plankbot
  class EtlAndAnnounceBamboohrAttendancesNotStart
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
          [attendances, "*These are the engineers out of office today (#{date_now}):*"]
        else
          s = attendances.select do |attendance|
            attendance.requestor.tags.where(kind: "team").exists?(name: k)
          end

          [s, "*These are the engineers out of office today for this team (#{date_now}):*"]
        end

        next if selected.blank?

        begin
          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: channel,
            text:  selected.map.with_index{|a| "#{icon(a.kind)} <#{ENV["PLANKBOT_HOST"]}/reviewers/#{a.requestor.id}/attendances|#{a.requestor.name}> requested a short notice OOO _(#{a.kind} - #{a.note})_" }.join("\n"),
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
