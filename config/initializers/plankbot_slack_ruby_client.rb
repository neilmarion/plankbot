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

Sidekiq::Cron::Job.create({
  name: 'Plankbot::EtlReleasesWorker',
  cron: '*/10 * * * *',
  class: 'Plankbot::EtlReleasesWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::SendDailyStatsWorker',
  cron: '*/10 * * * *',
  class: 'Plankbot::SendDailyStatsWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::RemindReviewersWorker',
  cron: '*/10 * * * *',
  class: 'Plankbot::RemindReviewersWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::RefreshAndAnnounceRepoVersionWorker',
  cron: '*/1 * * * *',
  class: 'Plankbot::RefreshAndAnnounceRepoVersionWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::EtlPullRequestsWorker',
  cron: '*/1 * * * *',
  class: 'Plankbot::EtlPullRequestsWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::SendDailyScrumCeremoniesWorker',
  cron: '0 18 * * *',
  class: 'Plankbot::SendDailyScrumCeremoniesWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::SendFeedbackReminderWorker',
  cron: '30 12 * * WED',
  class: 'Plankbot::SendFeedbackReminderWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::EtlCriticalIssuesWorker',
  cron: '*/5 * * * *',
  class: 'Plankbot::EtlCriticalIssuesWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::EtlAndAnnounceBamboohrAttendancesStartWorker',
  cron: '0 6 * * *',
  class: 'Plankbot::EtlAndAnnounceBamboohrAttendancesStartWorker'
})

Sidekiq::Cron::Job.create({
  name: 'Plankbot::EtlAndAnnounceBamboohrAttendancesNotStartWorker',
  cron: '0 * * * *',
  class: 'Plankbot::EtlAndAnnounceBamboohrAttendancesNotStartWorker'
})
