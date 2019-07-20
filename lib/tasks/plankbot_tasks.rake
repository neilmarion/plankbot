namespace :plankbot do
  desc 'Run Bot'
  task run: :environment do
    begin
      Plankbot::CommandBot.run
    rescue Exception => e
      STDERR.puts "ERROR: #{e}"
      STDERR.puts e.backtrace
      raise e
    end
  end

  task :stop, [:pid_file] => [:environment] do |task, args|
    begin
      data = File.read(args[:pid_file])
      Process.kill(9, data.to_i)
    rescue Errno::ENOENT
      puts "No pid file"
    rescue Errno::ESRCH
      puts "No such process"
    end
  end
end
