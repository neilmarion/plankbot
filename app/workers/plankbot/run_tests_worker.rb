module Plankbot
  class RunTestsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform
      waitings = TestRun.where(status: "waiting").
        order(created_at: :asc).
        where(status: "waiting")
      waitings.each do |w|
        w.start
      end
    end
  end
end
