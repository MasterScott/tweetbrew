require "spec_helper"

describe :formula_info do
  it "extracts homepage" do
    info = formula_info("Library/Formula/ruby.rb", "homebrew")
    expect(info[:home]).to eq("https://www.ruby-lang.org/")
  end

  it "extracts doi and tag for Homebrew/science formulae" do
    info = formula_info("a5.rb", "homebrew-science")
    expect(info[:doi]).to eq("10.1371/journal.pone.0042304")
    expect(info[:tag]).to eq("bioinformatics")
  end
end
