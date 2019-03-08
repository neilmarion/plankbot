module Plankbot
  class SettingsController < ApplicationController
    def shutdown
      shutdown_dates = Setting.default.shutdown_dates << "*"
      Setting.default.update_attributes(shutdown_dates: shutdown_dates)

      redirect_to pull_requests_path
    end

    def bootup
      shutdown_dates = Setting.default.shutdown_dates.reject!{ |x| x == "*" }
      Setting.default.update_attributes(shutdown_dates: shutdown_dates)

      redirect_to pull_requests_path
    end
  end
end
