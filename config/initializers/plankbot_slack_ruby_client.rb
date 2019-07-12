require 'sidekiq-cron'

Slack.configure do |config|
  config.token = ENV['PLANKBOT_SLACK_API_TOKEN']
end

# Send Release Notes every Friday

Sidekiq::Cron::Job.create({
  name: 'Plankbot::SendWeeklyReleaseNotesWorker',
  cron: '00 16 * * FRI',
  class: 'Plankbot::SendWeeklyReleaseNotesWorker'
})
