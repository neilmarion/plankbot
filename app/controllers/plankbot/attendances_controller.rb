module Plankbot
  class AttendancesController < ApplicationController
    def index
      current_date = (DateTime.now + 8.hours).to_date
      @date = params[:date]&.to_date || current_date

      unless @date.saturday? || @date.sunday? || @date > current_date || @date.to_s < "2020-03-01"
        employee = Reviewer.where.not(bamboohr_id: nil)

        @attendances = employee.inject({}) do |hash, employee|
          attendance = employee.attendances.find_by(date: @date)

          hash[employee.id] = { name: employee.name, ooo: attendance&.kind ? true : false, kind: attendance&.kind || "in office", note: attendance&.note || "" }
          hash
        end.sort_by{|k, v| v[:kind] }
      else
        @attendances = {}
      end
    end
  end
end
