module Plankbot
  class Setting < ApplicationRecord
    def self.default
      Setting.first
    end

    def self.is_within_first_10_minutes_of_longest_shutdown?
      shutdown_times.each do |t|
        if Time.current.between?(t[:from], t[:to])
          return false if shutdown_times.
            select{ |x| t[:length] < x[:length] }.present?

          if Time.current.between?(t[:from], t[:from] + 10.minutes)
            return true
          else
            return false
          end
        end
      end

      return false
    end

    def self.is_shutdown?
      return true if is_within_shutdown_time? ||
        is_within_shutdown_week_days? ||
        is_within_shutdown_specific_days? ||
        is_indefinitely_shutdown?

      return false
    end

    def self.is_within_shutdown_time?
      shutdown_times.each do |t|
        return true if Time.current.between?(t[:from], t[:to])
      end

      return false
    end

    def self.is_within_shutdown_week_days?
      return Setting.default.
        shutdown_week_days.include? Time.current.strftime('%A')
    end

    def self.is_within_shutdown_specific_days?
      return Setting.default.
        shutdown_dates.include? Time.current.strftime('%Y-%m-%d')
    end

    def self.is_indefinitely_shutdown?
      return Setting.default.
        shutdown_dates.include? "*"
    end

    def self.is_within_scheduled_shutdown?
      return true if is_within_shutdown_week_days? ||
        is_within_shutdown_specific_days? ||
        is_within_shutdown_time?

      return false
    end

    private

    def self.shutdown_times
      shutdown_times = Setting.default.shutdown_times
      times = shutdown_times.map do |shutdown_time|
        times = shutdown_time.split('-')
        time_from = Time.parse(times.first + " +08:00")
        time_to = Time.parse(times.last + " +08:00")
        time_now = Time.current

        if time_now <= time_to && time_to < time_from
          time_from = time_from - 1.day
        elsif time_now > time_to && time_to < time_from
          time_to = time_to + 1.day
        end

        {
          from: time_from,
          to: time_to,
          length: time_to - time_from,
        }
      end
    end
  end
end
