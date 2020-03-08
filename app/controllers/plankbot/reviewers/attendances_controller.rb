module Plankbot
  module Reviewers
    class AttendancesController < ApplicationController
      def index
        @reviewer = Reviewer.find(params[:reviewer_id])
        @attendances = @reviewer.attendances
        @current_date = Date.today
        @first_attendance_date = Attendance.first.date
      end
    end
  end
end
