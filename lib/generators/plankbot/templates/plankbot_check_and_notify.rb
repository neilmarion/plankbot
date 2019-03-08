require 'check_and_notify'

CheckAndNotify::Callbacks.check_after_one_minute do
  Plankbot::EtlPullRequests.execute
  return
end

CheckAndNotify::Callbacks.check_after_ten_minutes do
  Plankbot::RemindReviewers.execute
  return
end

CheckAndNotify::Callbacks.check_after_ten_minutes do
  Plankbot::SendDailyStats.execute
  return
end

CheckAndNotify.init_cron
