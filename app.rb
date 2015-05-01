require "json"
require "openssl"
require "rack"
require "sinatra"

def verify_signature(payload_body, request_signature)
  signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"),
                                                ENV["GITHUB_WEBHOOK_TOKEN"],
                                                payload_body)
  unless Rack::Utils.secure_compare(signature, request_signature)
    halt 500, "Signatures didn't match!"
  end
end

def process(payload)
end

post "/payload" do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body, request.env["HTTP_X_HUB_SIGNATURE"])
  process(JSON.parse(payload_body))
end
