module Plankbot
  class AnnounceRepoVersion
    def self.execute(pull_request:, approvers:)
      RepoVersion.refresh_and_announce_repo_version
    end
  end
end
