# frozen_string_literal: true

require "spec_helper"

# The parse path stores the input spelling of the typed stage
# (`typed_stage.original_abbr`: "Amd.", "COR", "DAmd"); `from_hash` stores the
# canonical one ("Amd", "Cor", "DAM"). The spelling is not serialized, so the
# two must still be ==, or `#matches?` against an index row fails silently.
RSpec.describe "ISO typed-stage spelling survives a hash round trip" do
  [
    "ISO 9001:2015/Amd. 1:2020",
    "ISO 9001:2015/Amd.1",
    "ISO 105-B01:1994/AMD 1:1998",
    "ISO 9606-1:2012/Cor.2:2013(F)",
    "ISO 105-G01:1993/COR 1:1995",
    "ISO 10993-18:2020/DAmd 1",
    "ISO 11137-2:2013/FDAmd 1",
    "ISO/IEC 10646-1:1993/pDCOR.2",
    "ISO/IEC Directives Part 1",
    "ISO/GUIDE 1:1972",
    "ISO/NWIP 19144-4",
  ].each do |input|
    it "restores an == identifier for #{input.inspect}" do
      id = Pubid::Iso.parse(input)
      back = Pubid.from_hash(id.to_hash)

      expect(back).to eq(id)
      expect(back.hash).to eq(id.hash)
      expect(id.matches?(back, ignore: [])).to be(true)
    end
  end
end
