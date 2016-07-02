require "spec_helper"

describe :app do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "when signature verification failed" do
    before do
      header "X-Hub-Signature", ""
      allow(Rack::Utils).to receive(:secure_compare).and_return(false)
    end

    it "halts" do
      post "/payload", {}.to_json
      expect(last_response).not_to be_ok
      expect(last_response.body).to eq("Signatures didn't match!")
    end
  end

  context "when signature verification succeeded" do
    before do
      header "X-Hub-Signature", ""
      allow(Rack::Utils).to receive(:secure_compare).and_return(true)
    end

    it "returns OK for ping event" do
      header "X-Github-Event", "ping"
      post "/payload", { "repository" => { "full_name" => "Homebrew/homebrew-core" } }.to_json
      expect(last_response).to be_ok
      expect(last_response.body).to eq("Ping event from Homebrew/core.")
    end

    it "skips for non-master push event" do
      header "X-Github-Event", "push"
      post "/payload", { "repository" => { "full_name" => "Homebrew/homebrew-core" },
                         "ref" => "refs/heads/gh-pages" }.to_json
      expect(last_response).to be_ok
      expect(last_response.body).to eq("Skip non-master push event.")
    end

    it "halts for non-push event" do
      header "X-Github-Event", "not-push"
      post "/payload", { "repository" => { "full_name" => "Homebrew/homebrew-core"} }.to_json
      expect(last_response).not_to be_ok
      expect(last_response.body).to eq("Only push event is allowed!")
    end
  end
end
