module Plankbot
  class AttendancesController < ApplicationController
    def index
      current_date = (DateTime.now + 8.hours).to_date
      @date = params[:date]&.to_date || current_date

      @employees = Reviewer.where.not(bamboohr_id: nil)
      @signed_in_employees = @employees.select do |e|
        e.signed_in?(@date)
      end

      @signed_out_employees = @employees.select do |e|
        !e.signed_in?(@date)
      end

      @employees = @signed_in_employees + @signed_out_employees
    end
  end
end
