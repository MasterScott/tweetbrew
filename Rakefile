task :default => :up

desc "Start the bot."
task :up do
  sh "bundle exec rackup config.ru"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)
desc "Run the test."
task :test => :spec
