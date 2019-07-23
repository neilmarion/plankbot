module Plankbot
  module CodeReview
    class ExtractPullRequests
      def self.execute
        pull_requests = []

        repos = JSON.parse(ENV["PLANKBOT_REPOS"])

        repos.each do |repo|
          pull_requests = pull_requests + HTTParty.get("https://api.github.com/repos/#{repo["github_repo"]}/pulls?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}")
        end

        pull_requests
      end
    end
  end
end
