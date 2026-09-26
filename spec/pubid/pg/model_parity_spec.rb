# frozen_string_literal: true

require "json"

RSpec.describe "R3 relaton compatibility" do
  fixture = File.join(__dir__, "fixtures", "iso_model_relaton.json")
  records = JSON.parse(File.read(fixture))

  it "freezes the pre-swap engine's model outputs" do
    expect(records).to be_an(Array)
    expect(records.size).to be > 300
  end

  it "renders model JSON byte-identical to the pre-swap engine" do
    records.each do |record|
      id = Pubid::Iso::Identifier.parse(record["input"])

      expect(id.to_s).to eq(record["to_s"])
      expect(JSON.generate(id.to_hash)).to eq(record["hash"])
    end
  end
end
