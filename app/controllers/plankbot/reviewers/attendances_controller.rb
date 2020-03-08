module Plankbot
  module Reviewers
    class AttendancesController < ApplicationController
      def index
        @reviewer = Reviewer.find(params[:reviewer_id])
        @attendances = @reviewer.attendances
        @current_date = (DateTime.now + 8.hours).to_date
        @first_attendance_date = Attendance.first.date
      end
    end
  end
end
