require "sinatra"
require "openssl"
require "rack"
require "twitter"

def verify_signature(payload_body, request_signature)
  signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"),
                                                ENV["GITHUB_WEBHOOK_TOKEN"],
                                                payload_body)
  unless Rack::Utils.secure_compare(signature, request_signature)
    halt 500, "Signatures didn't match!"
  end
end

def doi2url(doi)
  case doi
  when /^arXiv:/ then "http://arxiv.org/abs/#{doi.sub(/^arXiv:/, "")}"
  else "http://doi.org/#{doi}"
  end
end

def twitter_client(tap)
  token_suffix = tap.official? ? "_#{TWITTER_ACCOUNT_MAP[tap.repo].upcase}" : ""
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SEC"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN#{token_suffix}"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SEC#{token_suffix}"]
  end
end
