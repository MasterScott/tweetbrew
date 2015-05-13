require "spec_helper"

describe Tap do
  let(:core) { Tap.new "Homebrew/homebrew" }
  let(:science) { Tap.new "Homebrew/homebrew-science" }
  let(:unofficial) { Tap.new "Test/homebrew-test" }

  it "check whether it is official tap" do
    expect(core.official?).to eq(true)
    expect(science.official?).to eq(true)
    expect(unofficial.official?).to eq(false)
  end

  it "check whether it is core or tap" do
    expect(core.core?).to eq(true)
    expect(science.core?).to eq(false)
    expect(unofficial.core?).to eq(false)
  end

  it "check whether a file is formula" do
    expect(core.formula? "Library/Homebrew/global.rb").to eq(false)
    expect(core.formula? "Library/Formula/global.rb").to eq(true)
    expect(science.formula? "a5.rb").to eq(true)
    expect(science.formula? "Formula/a5.rb").to eq(true)
    expect(science.formula? "HomebrewFormula/a5.rb").to eq(true)
  end
end

describe Formula do
  let(:tap) { Tap.new "Homebrew/homebrew-science" }
  let(:formula) { Formula.new tap, "a5.rb"}

  it "extracts homepage" do
    expect(formula.homepage).to eq("https://sourceforge.net/projects/ngopt/")
  end

  it "extracts doi and tag if possible" do
    expect(formula.doi).to eq("10.1371/journal.pone.0042304")
    expect(formula.tag).to eq("bioinformatics")
  end
end
