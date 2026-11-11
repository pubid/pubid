# frozen_string_literal: true

require "spec_helper"

# A wrapper (Vap/Consolidated/Sheet/Fragment) delegates `date` to what it
# wraps, so the date belongs inside "base"/"identifiers" only. The four date
# keys used to be mapped on Pubid::Iec::Identifier, and the wrappers no-opped
# only `year`, so `month`, `day` and `undated` leaked a duplicate top-level
# key. The maps now live on Pubid::Iec::SingleIdentifier, which the wrappers do
# not inherit from, so the exclusion is structural.
RSpec.describe "IEC wrapper date keys" do
  let(:date_keys) { %w[year month day undated] }

  wrappers = [
    Pubid::Iec::Identifiers::VapIdentifier,
    Pubid::Iec::Identifiers::ConsolidatedIdentifier,
    Pubid::Iec::Identifiers::SheetIdentifier,
    Pubid::Iec::Identifiers::FragmentIdentifier,
    Pubid::Iec::Identifiers::AllParts,
  ]

  describe "structural placement" do
    it "maps the date keys on SingleIdentifier" do
      keys = Pubid::Iec::SingleIdentifier.mappings_for(:hash)
        .mappings.map(&:name)

      expect(keys).to include(*date_keys)
    end

    wrappers.each do |klass|
      it "maps no date key on #{klass.name.split('::').last}" do
        keys = klass.mappings_for(:hash).mappings.map(&:name)

        expect(keys & date_keys).to eq([])
      end
    end
  end

  {
    "IEC CA 01:2025-10 CSV" =>
      [Pubid::Iec::Identifiers::VapIdentifier, "base", "month"],
    "IEC 60050-1:2020-10-03 CSV" =>
      [Pubid::Iec::Identifiers::VapIdentifier, "base", "day"],
    "IEC 60050:-- CSV" =>
      [Pubid::Iec::Identifiers::VapIdentifier, "base", "undated"],
    "IEC CA 01:2025-10+AMD1:2026" =>
      [Pubid::Iec::Identifiers::ConsolidatedIdentifier, "identifiers", "month"],
    "IEC 60050:--+AMD1:2005" =>
      [Pubid::Iec::Identifiers::ConsolidatedIdentifier, "identifiers",
       "undated"],
    "IEC 60695-2-1:2025-10/0:1994" =>
      [Pubid::Iec::Identifiers::SheetIdentifier, "base", "month"],
    "IEC 60050:--/0:1994" =>
      [Pubid::Iec::Identifiers::SheetIdentifier, "base", "undated"],
    "IEC CA 01:2025-10/FRAG1" =>
      [Pubid::Iec::Identifiers::FragmentIdentifier, "base", "month"],
    "IEC 60050:--/FRAG1" =>
      [Pubid::Iec::Identifiers::FragmentIdentifier, "base", "undated"],
  }.each do |input, (klass, inner_key, date_key)|
    context input do
      let(:id) { Pubid::Iec.parse(input) }
      let(:hash) { id.to_hash }
      let(:inner) { [hash[inner_key]].flatten.first }

      it "parses to #{klass.name.split('::').last}" do
        expect(id).to be_a(klass)
      end

      it "omits every date key at the top level" do
        expect(hash.keys & date_keys).to eq([])
      end

      it "keeps #{date_key} inside #{inner_key}" do
        expect(inner).to include(date_key)
      end

      it "round-trips through from_hash" do
        expect(Pubid::Iec::Identifier.from_hash(hash)).to eq(id)
      end

      it "round-trips through the pubid-scheme URN" do
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(hash)
      end
    end
  end

  # A row serialized before this change carries the leaked top-level key. It
  # must still deserialize to the same identifier; the stray key is ignored.
  it "reads a legacy hash that still carries the leaked month" do
    id = Pubid::Iec.parse("IEC CA 01:2025-10 CSV")
    legacy = id.to_hash.merge("month" => "10")

    expect(Pubid::Iec::Identifier.from_hash(legacy)).to eq(id)
  end

  it "keeps the date keys on a plain standard" do
    hash = Pubid::Iec.parse("IEC CA 01:2025-10").to_hash

    expect(hash).to include("year" => "2025", "month" => "10")
  end
end
