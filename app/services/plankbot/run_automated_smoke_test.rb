require 'open3'

module Plankbot
  class RunAutomatedSmokeTest
    def self.execute
      cmd_array = []
      root_directory = Rails.root


      cmd = "echo 'cloning first-circle-qa-automation';" +
      "cd #{root_directory}/tmp;" +
      "git clone git@github.com:carabao-capital/first-circle-qa-automation.git;"
      cmd_array << cmd

      cmd = "echo 'creating results directory';" +
        "cd #{root_directory}/tmp;" +
        "mkdir ../public/results/"
      cmd_array << cmd

      cmd = "cd #{root_directory}/tmp;" +
      "pabot --processes 6 -A first-circle-qa-automation/argument_file.txt -d ../public/results/#{DateTime.now.to_i}/ -v ENV_FCC:preprod -v ENV_FCA:new-preprod -i smoke first-circle-qa-automation/src/firstcircle/testsuite/"
      cmd_array << cmd

      cmd = "echo 'deleting first-circle-qa-automation';" +
        "cd #{root_directory}/tmp; rm -rf first-circle-qa-automation"
      cmd_array << cmd

      cmd_array.each do |cmd|
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          puts "stdout is:" + stdout.read
          puts "stderr is:" + stderr.read

          if cmd.match /pabot/
            if wait_thr.value.to_s.match /exit 13/
              puts "Result: failed"
            else
              puts "Result: passed"
            end
          end
        end
      end
    end
  end
end
