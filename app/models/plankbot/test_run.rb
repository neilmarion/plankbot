module Plankbot
  class TestRun < ApplicationRecord
    after_create :cancel_all_with_same_branches

    STATUSES = {
      waiting: "waiting",
      deploying: "deploying",
      testing: "testing",
      passed: "passed",
      failed: "failed",
      canceled: "canceled",
    }

    def start
      RunTestWorker.perform_async(id)
    end

    def cancel
      Plankbot::RunTest.cancel(self)
    end

    def is_canceled?
      reload.status == STATUSES[:canceled]
    end

    def show_canceled_button?
      status != STATUSES[:canceled] &&
      status != STATUSES[:passed] &&
      status != STATUSES[:failed]
    end

    def passed_or_failed?
      status == STATUSES[:passed] ||
      status == STATUSES[:failed]
    end

    private

    def cancel_all_with_same_branches
      Plankbot::TestRun.where(github_branch: github_branch).
        where.not(id: id).
        where("status = ? OR status = ? OR status = ?",
              STATUSES[:waiting],
              STATUSES[:deploying],
              STATUSES[:testing]).each do |t|
                t.cancel
              end
    end
  end
end
