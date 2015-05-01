ENV["RACK_ENV"] = "test"
ENV["GITHUB_WEBHOOK_TOKEN"] = ""

require "rspec"
require "rack/test"
require_relative "../app.rb"
