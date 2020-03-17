module Plankbot
  class EtBamboohrEmployees
    def execute
      result = HTTParty.get(
        "https://api.bamboohr.com/api/gateway.php/firstcircle/v1/employees/directory",
        basic_auth: { username: ENV["BAMBOOHR_API_KEY"], password: "x" },
        headers: { "Accept" => "application/json", "User-Agent" => "Bamboozled/0.2.0" },
      )

      result = JSON.parse(result.body)

      employees = Plankbot::Reviewer.where.not(bamboohr_id: nil)

      engineers = result["employees"].select do |x|
        employees.pluck(:bamboohr_id).include? x["id"]
      end.inject({}) do |hash, x|
        employees.find_by(bamboohr_id: x["id"]).update_attributes(photo: x["photoUrl"])
        hash[x["id"]] = {name: x["displayName"], photo: x["photoUrl"]}
        hash
      end
    end
  end
end
