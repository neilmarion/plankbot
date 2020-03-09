require 'bamboozled'

module Plankbot
  class EtlBamboohrAttendances
    def execute(date=nil)
      date_now = date || (DateTime.now + 8.hours).to_date.to_s

      extracted_requests = extract(date_now)
      transformed_requests = transform(extracted_requests)
      lod(transformed_requests, date_now)
    end

    private

    def extract(date_now)
      client = Bamboozled.client(subdomain: "firstcircle", api_key: ENV["BAMBOOHR_API_KEY"])

      result = HTTParty.get(
        "https://api.bamboohr.com/api/gateway.php/firstcircle/v1/time_off/requests/?start=#{date_now}&end=#{date_now}",
        basic_auth: { username: ENV["BAMBOOHR_API_KEY"], password: "x" },
        headers: { "Accept" => "application/json", "User-Agent" => "Bamboozled/0.2.0" },
      )

      JSON.parse(result.body)
    end

    def transform(extracted_requests)
      eng_employee_ids = Plankbot::Reviewer.where.not(bamboohr_id: nil).pluck(:bamboohr_id).compact.map(&:to_i)

      extracted_requests.inject([]) do |array, request|
        if (eng_employee_ids.include? request["employeeId"].to_i) && (request["status"]["status"] != "canceled" && request["status"]["status"] != "denied")
          array << { employee_id: request["employeeId"], kind: request["type"]["name"], note: note(request) }
        end

        array
      end
    end

    def lod(transformed_requests, date_now)
      transformed_requests.inject([]) do |array, request|
        employee = Plankbot::Reviewer.find_by(bamboohr_id: request[:employee_id])
        if  employee.present? && !employee.attendances.exists?(date: date_now, kind: request[:kind])
          attendance = employee.attendances.create(date: date_now, kind: request[:kind], note: request[:note])
          array << attendance.id
        end

        array
      end
    end

    private

    def note(request)
      return "" if request["notes"].blank?
      "#{request["notes"]["employee"]}"
    end
  end
end
