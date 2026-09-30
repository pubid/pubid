# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# pubid#465: a joint ISO/IEC identifier parses in both Pubid::Iso and
# Pubid::Iec, and the two to_hash differ, so a cache or an index keyed by
# to_hash holds one document twice. canonical_hash is the flavor-independent
# key: the to_hash of the lead publisher's reading (Pubid::JOINT_LEADS).
RSpec.describe "Pubid::Identifier#canonical_hash" do
  [
    "ISO/IEC 27001:2022",
    "ISO/IEC/IEEE 9945:2009",
    "ISO/IEC DIR JTC 1 SUP:2023",
    "ISO/IEC 27001:2013/Cor 1:2014",
  ].each do |ref|
    context ref do
      let(:iso) { Pubid::Iso.parse(ref) }
      let(:iec) { Pubid::Iec.parse(ref) }

      it "is the same for the ISO and the IEC reading" do
        expect(iec.canonical_hash).to eq(iso.canonical_hash)
      end

      it "is the lead publisher's to_hash" do
        expect(iec.canonical_hash).to eq(iso.to_hash)
      end

      it "leaves the IEC reading's own to_hash unchanged" do
        before = iec.to_hash
        iec.canonical_hash

        expect(iec.to_hash).to eq(before)
        expect(before["_type"]).to start_with("pubid:iec:")
      end
    end
  end

  it "is the IEC reading for an IEC-led joint identifier" do
    ref = "IEC/ISO 31010:2019"

    expect(Pubid::Iso.parse(ref).canonical_hash)
      .to eq(Pubid::Iec.parse(ref).to_hash)
  end

  # A reading is accepted only for the same document. IEC reads
  # "ISO/IEC/IEEE 29148-2018" with 2018 as a part and no year; that reading
  # renders the same string but is another document, so the IEEE reading
  # keeps its own key rather than taking the wrong one.
  it "refuses another flavor's reading of a different document" do
    ieee = Pubid::Ieee.parse("ISO/IEC/IEEE 29148-2018")

    expect(ieee.canonical_hash).to eq(ieee.to_hash)
  end

  # ISO has no RLV (redline version) type, so the IEC reading is the only one.
  it "is to_hash for a joint identifier the lead flavor cannot read" do
    iec = Pubid::Iec.parse("ISO/IEC 27001:2022 RLV")

    expect(iec.canonical_hash).to eq(iec.to_hash)
  end

  it "is to_hash for an identifier with no joint prefix" do
    id = Pubid::Iso.parse("ISO 9001:2015")

    expect(id.canonical_hash).to eq(id.to_hash)
  end

  it "is to_hash for a joint prefix with no lead (ANSI accreditation)" do
    id = Pubid::Ashrae.parse("ANSI/ASHRAE 90.1-2019")

    expect(id.canonical_hash).to eq(id.to_hash)
  end

  it "keys a from_hash round trip the same as the parse" do
    iec = Pubid::Iec.parse("ISO/IEC 27001:2022")

    expect(Pubid.from_hash(iec.to_hash).canonical_hash)
      .to eq(iec.canonical_hash)
  end
end
