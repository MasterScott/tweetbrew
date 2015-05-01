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
      post "/payload", { "repository" => { "full_name" => "test" } }.to_json
      expect(last_response).to be_ok
      expect(last_response.body).to eq("Ping event from test.")
    end

    it "halts for non-push event" do
      header "X-Github-Event", "not-push"
      post "/payload", {}.to_json
      expect(last_response).not_to be_ok
      expect(last_response.body).to eq("Only push event is allowed!")
    end
  end
end
