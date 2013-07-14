GAME_FILE = File.join(__dir__, 'app', 'main.rb')

desc "Run game"
task :run do
  gamePid = Process.spawn("bundle exec ruby #{GAME_FILE}")
  
  trap("INT") {
    Process.kill(9, gamePid) rescue Errno::ESRCH
    exit 0
  }
  
  Process.wait(gamePid)
end

task :default => :run
