$:.unshift(File.expand_path("#{File.dirname(__FILE__)}/app"))
require "tweetbrew"
require "json"

post "/payload" do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, request.env["HTTP_X_HUB_SIGNATURE"])
  payload = JSON.parse(payload_body)
  tap = Tap.new payload["repository"]["full_name"]
  event = request.env["HTTP_X_GITHUB_EVENT"]
  halt "Ping event from #{tap.name}." if event == "ping"
  halt 500, "Only push event is allowed!" unless event == "push"
  halt "Skip non-master push event." unless payload["ref"] == "refs/heads/master"
  new_files = payload["commits"].reduce([]) { |files, commit| files += commit["added"] }
  new_formulae = new_files.select { |f| tap.formula? f }.map { |f| Formula.new tap, f }
  new_formulae.map do |formula|
    tweet = "New formula #{formula.name}"
    tweet += " in #{tap.name}"
    tweet += " #{formula.homepage}"
    tweet += " #{doi2url(formula.doi)}" if formula.doi
    tweet += " ##{formula.tag}" if formula.tag
    puts "==> Send tweet: #{tweet}"
    twitter_client(tap).update(tweet).uri.to_s
  end.join("\n")
end
