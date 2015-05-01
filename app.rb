require "json"
require "openssl"
require "rack"
require "sinatra"
require "twitter"
require "unirest"

def verify_signature(payload_body, request_signature)
  signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"),
                                                ENV["GITHUB_WEBHOOK_TOKEN"],
                                                payload_body)
  unless Rack::Utils.secure_compare(signature, request_signature)
    halt 500, "Signatures didn't match!"
  end
end

def formula_info(formula, tap)
  code = Unirest.get("https://raw.githubusercontent.com/Homebrew/#{tap}/master/#{formula}").raw_body
  {
    :home => code.match(/homepage ['"]([^'"]+)['"]/) ? $1 : nil,
    :doi => code.match(/doi ['"]([^'"]+)['"]/) ? $1 : nil,
    :tag => code.match(/tag ['"]([^'"]+)['"]/) ? $1 : nil,
  }
end

def send_tweet(tap, tweet)
  account = case tap
            when "homebrew-science" then "brew_sci"
            else "MacHomebrew"
            end
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY_#{account.upcase}"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SEC_#{account.upcase}"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN_#{account.upcase}"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SEC_#{account.upcase}"]
  end
  client.update(tweet)
end

def process(payload, event)
  halt "Ping event from #{payload["repository"]["full_name"]}." if event == "ping"
  halt 500, "Only push event is allowed!" unless event == "push"
  halt "Skip non-master push event." unless payload["ref"] == "refs/heads/master"
  tap = payload["repository"]["name"]
  new_files = payload["commits"].reduce([]) { |files, commit| files += commit["added"] }
  new_formulae = case tap
                 when "homebrew"
                   new_files.select { |file| file.match %r{^Library/Formula/[^/]+\.rb$} }
                 when "homebrew-science"
                   new_files.select { |file| file.match %r{^((Homebrew)?Formula/)?[^/]+\.rb$} }
                 else
                   halt 500, "Bot isn't enabled yet in #{tap}."
                 end
  new_formulae.map do |formula|
    name = File.basename(formula, ".rb")
    info = formula_info(formula, tap)
    tweet = "New formula #{name}"
    tweet += " in Homebrew/#{tap.gsub "homebrew-", "" }" unless tap == "homebrew"
    tweet += " #{info[:home]}"
    tweet += " http://doi.org/#{info[:doi]}" if info[:doi]
    tweet += " ##{info[:tag]}" if info[:tag]
    puts "==> Send tweet: #{tweet}"
    send_tweet(tap, tweet)
  end.map(&:full_text).join("\n\n")
end

post "/payload" do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, request.env["HTTP_X_HUB_SIGNATURE"])
  process(JSON.parse(payload_body), request.env["HTTP_X_GITHUB_EVENT"])
end
