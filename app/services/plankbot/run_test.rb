require 'open3'

module Plankbot
  class RunTest
    FCC = "first-circle-app"
    FCA = "first-circle-account"

    def self.execute(test_run)
      begin
        stack_id = if test_run.github_repo == FCC
          ENV['PLANKBOT_FCC_PREPROD_STACK_ID']
        elsif test_run.github_repo == FCA
          ENV['PLANKBOT_FCA_PREPROD_STACK_ID']
        end

        test_run.update_attributes(
          log: test_run.reload.log + "Waiting for #{test_run.github_commit_hash} to be deployed" + "\n",
        )

        loop do
          return if test_run.is_canceled?
          test_run.update_attributes(status: TestRun::STATUSES[:deploying])
          response = HTTParty.get("https://app.cloud66.com/api/3/stacks/#{stack_id}/deployments",
            :headers => { "Authorization" => "Bearer #{ENV['PLANKBOT_CLOUD66_AUTH_CODE']}" }
          )

          break if response.parsed_response["response"].any? do |d|
            d["is_live"] && d["git_hash"] == test_run.github_commit_hash
          end
        end

        return if test_run.is_canceled?

        cmd_array = []
        root_directory = Rails.root

        cmd = "echo 'cloning first-circle-qa-automation';" +
        "cd #{root_directory}/tmp;" +
        "git clone git@github.com:carabao-capital/first-circle-qa-automation.git;"
        cmd_array << cmd

        cmd = "echo 'creating results directory';" +
          "cd #{root_directory}/tmp;" +
          "mkdir ../public/results/;" +
          "echo 'testing... logs will only appear after the test'"
        cmd_array << cmd

        result_artifacts_id = DateTime.now.to_i
        test_run.update_attributes(result_artifacts_id: result_artifacts_id)
        cmd = "cd #{root_directory}/tmp;" +
        "chromedriver --url-base=/wd/hub &;" +
        "pabot --processes 6 -A first-circle-qa-automation/argument_file.txt -d ../public/results/#{result_artifacts_id}/ -v ENV_FCC:preprod -v ENV_FCA:new-preprod -i smoke first-circle-qa-automation/src/firstcircle/testsuite/"
        cmd_array << cmd

        cmd = "echo 'deleting first-circle-qa-automation';" +
          "cd #{root_directory}/tmp; rm -rf first-circle-qa-automation"
        cmd_array << cmd

        cmd_array.each do |cmd|
          return if test_run.is_canceled?

          Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
            test_run.update_attributes(test_pid: wait_thr.pid)

            test_run.update_attributes(
              log: test_run.reload.log + stdout.read + "\n" + stderr.read,
            )

            if cmd.match /pabot/
              if wait_thr.value.to_s.match /exit 13/
                test_run.update_attributes(
                  status: TestRun::STATUSES[:failed],
                )
              else
                test_run.update_attributes(
                  status: TestRun::STATUSES[:passed],
                )
              end
            end
          end
        end
      rescue StandardError => e
        test_run.update_attributes(
          log: test_run.reload.log + "Exception Thrown:\n" + e.message + "\n" + e.backtrace + "\n",
          status: TestRun::STATUSES[:failed],
        )
      end
    end

    def self.cancel(test_run)
      test_run.update_attributes({
        status: TestRun::STATUSES[:canceled],
        log: test_run.log + "canceled",
      })
      begin
        Process.kill("TERM", test_run.test_pid) if test_run.test_pid
      rescue StandardError => e

      end
    end
  end
end
