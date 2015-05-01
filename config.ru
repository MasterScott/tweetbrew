require_relative "app"

# enable realtime logging
$stdout.sync = true

run Sinatra::Application
