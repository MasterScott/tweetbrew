$:.unshift(File.expand_path("#{File.dirname(__FILE__)}/app"))
require "tweetbrew"
require "json"
require "omniauth-twitter"

configure do
  enable :sessions

  use OmniAuth::Builder do
    provider :twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SEC"]
  end
end

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

get "/" do
  if session[:uid]
    "<ul><li>Token: #{session[:twitter_token]}</li><li>Token Secret: #{session[:twitter_token_sec]}</li></ul>"
  else
    '<a href="/auth/twitter"><button>Generate Twitter Token</button></a>'
  end
end

get "/auth/twitter/callback" do
  session[:uid] = env["omniauth.auth"]["uid"]
  session[:twitter_token] = env["omniauth.auth"].credentials.token
  session[:twitter_token_sec] = env["omniauth.auth"].credentials.secret
  redirect to("/")
end

