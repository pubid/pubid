# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid"

# pubid#215: the joint ISO-print carries a Redline marker and the dotted
# corrigendum spelling. A redline is a distinct document of the same standard
# — the flag must survive the parse and print on both faces, never collapse.
RSpec.describe "Pubid::Ieee joint ISO-print Redline and Cor.n:YYYY (pubid#215)" do
  {
    "ISO/IEC/IEEE 15289:2015(E) - Redline" => "ISO/IEC/IEEE 15289:2015 (E) - Redline",
    "ISO/IEC/IEEE 29119-2:2021(E) - Redline" => "ISO/IEC/IEEE 29119-2:2021 (E) - Redline",
    "ISO/IEC/IEEE 8802-3:2017/Cor.1:2018(E)" => "ISO/IEC/IEEE 8802-3:2017 (E)/Cor. 1-2018",
    "ISO/IEC/IEEE 8802-1AC:2018/Cor.1:2020(E)" => "ISO/IEC/IEEE 8802-1AC:2018 (E)/Cor. 1-2020",
  }.each do |input, canonical|
    it "parses #{input.inspect} and round-trips" do
      id = Pubid::Ieee.parse(input)
      expect(id.to_s).to eq(canonical)
      expect(Pubid::Ieee.parse(id.to_s)).to eq(id)
    end
  end

  it "keeps the redline flag on the joint identifier" do
    id = Pubid::Ieee.parse("ISO/IEC/IEEE 15289:2015(E) - Redline")
    expect(id.redline).to be(true)
    expect(id.to_hash["redline"]).to be(true)
  end

  it "wraps the corrigendum tail as a supplement of the base joint standard" do
    id = Pubid::Ieee.parse("ISO/IEC/IEEE 8802-3:2017/Cor.1:2018(E)")
    expect(id.class.name).to eq("Pubid::Ieee::Identifiers::Corrigendum")
    expect(id.root.to_s).to eq("ISO/IEC/IEEE 8802-3:2017 (E)")
  end

  it "leaves the redline-less joint print unchanged" do
    expect(Pubid::Ieee.parse("ISO/IEC/IEEE 15289:2015(E)").to_s)
      .to eq("ISO/IEC/IEEE 15289:2015 (E)")
    expect(Pubid::Ieee.parse("ISO/IEC/IEEE 15289:2015(E)").redline).to be_falsey
  end
end
