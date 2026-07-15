# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CalConnect URN generation" do
  it "generates a urn:calconnect: URN for a bare id" do
    urn = Pubid::Calconnect.parse("CC 18011:2018").to_urn
    expect(urn).to eq("urn:calconnect:18011:2018")
  end

  it "preserves the series case so the URN reconstructs losslessly" do
    urn = Pubid::Calconnect.parse("CC/DIR 10006:2019").to_urn
    expect(urn).to eq("urn:calconnect:DIR:10006:2019")
  end

  it "keeps the full date in the trailing segment" do
    urn = Pubid::Calconnect.parse("CC/WD 51017:2024-07-23").to_urn
    expect(urn).to eq("urn:calconnect:WD:51017:2024-07-23")
  end

  it "round-trips URN back to the exact printed form" do
    ["CC 18011:2018", "CC/DIR 10006:2019", "CC/Adv 0707.1:2007",
     "CC/WD 51017:2024-07-23"].each do |ref|
      urn = Pubid::Calconnect.parse(ref).to_urn
      expect(Pubid.parse(urn).to_s).to eq(ref)
    end
  end
end
