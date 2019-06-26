module Plankbot
  class RepoVersion < ApplicationRecord
    def self.refresh_and_announce_repo_version
      self.find_each do |rv|
        response = HTTParty.
          get(rv.github_api_endpoint + "?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}")
        version = response.parsed_response.first

        if version["name"] != rv.version
          rv.update_attributes(version: version["name"])

          PLANKBOT_SLACK_CLIENT.chat_postMessage(
            channel: "tech_coding",
            text: "*#{rv.repo_name}* is now <#{rv.github_versions_url}/tag/#{version["name"]}|#{version["name"]}> :arrow_up: <#{rv.github_versions_url}|releases>",
            as_user: true,
          )
        end
      end
    end
  end
end
