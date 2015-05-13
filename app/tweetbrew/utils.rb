require "sinatra"
require "openssl"
require "rack"

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

