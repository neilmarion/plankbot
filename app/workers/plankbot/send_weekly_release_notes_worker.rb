module Plankbot
  class SendWeeklyReleaseNotesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      time_now = DateTime.now
      releases = Plankbot::Release.
        where("release_date > ? AND release_date < ?", time_now - 7.days, time_now).
        order(release_date: :asc)

      releases = releases.map.with_index do |release, i|
        "- <https://firstcircle.atlassian.net/projects/#{release.team}/versions/#{release.jira_id}|#{release.name}> *#{release.description}*"
      end

      return if releases.blank?

      begin
        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_WEEKLY_RELEASE_NOTES_SLACK_CHANNEL"],
          text: ":arrow_up: *Engineering Weekly Release Notes*\n:spiral_calendar_pad: #{(time_now - 7.days).strftime('%Y %b %d')} to #{time_now.strftime('%Y %b %d')}\n\n#{releases.join("\n")}",
          as_user: true,
        )
      rescue Slack::Web::Api::Errors::SlackError => e
      end
    end
  end
end
