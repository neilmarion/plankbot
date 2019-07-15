module Plankbot
  class RefreshAndAnnounceRepoVersionWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      Plankbot::RepoVersion.refresh_and_announce_repo_version
    end
  end
end
