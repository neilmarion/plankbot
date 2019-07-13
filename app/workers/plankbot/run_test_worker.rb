module Plankbot
  class RunTestWorker
    include Sidekiq::Worker
    sidekiq_options retry: 1

    def perform(id)
      test_run = TestRun.find(id)
      Plankbot::RunTest.execute(test_run)
    end
  end
end
