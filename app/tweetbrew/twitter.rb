require "twitter"

def twitter_client(tap)
  token_suffix = tap.official? ? "_#{TWITTER_ACCOUNT_MAP[tap.repo].upcase}" : ""
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SEC"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN#{token_suffix}"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SEC#{token_suffix}"]
  end
end
