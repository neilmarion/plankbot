module Plankbot
  class ExtractPullRequests
    REPO_API_PULL_REQUESTS = [
      "https://api.github.com/repos/carabao-capital/first-circle-app/pulls?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}",
      "https://api.github.com/repos/carabao-capital/first-circle-account/pulls?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}",
      "https://api.github.com/repos/carabao-capital/firstcircle.ph/pulls?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}",
    ]

    def self.execute
      pull_requests = []

      REPO_API_PULL_REQUESTS.each do |repo|
        pull_requests = pull_requests + HTTParty.get(repo)
      end

      pull_requests
    end
  end
end
