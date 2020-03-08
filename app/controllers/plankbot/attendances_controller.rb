module Plankbot
  class AttendancesController < ApplicationController
    def index
      date = Date.today
      @date = params[:date]&.to_date || date

      unless @date.saturday? || @date.sunday? || @date > Date.today || @date.to_s < "2020-03-01"
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
