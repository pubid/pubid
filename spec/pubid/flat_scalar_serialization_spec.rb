# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# A component that carries only one meaningful value serializes as that value,
# and the bare value is accepted back. This is what makes an index row readable
# (`edition: '2'`, not `edition: {number: '2'}`) and what gives the metanorma
# mapping layer a shape it can write without knowing pubid's component classes.
#
# The rule is per IDENTIFIER, not per flavor. IEC's own corpus holds both
# shapes: 9,728 of its dated identifiers carry a year alone, but 10 carry a
# month (`IEC CA 01:2025-10`) and 2 are undated (`IEC 60050:--`). A
# flavor-wide switch would have thrown those away, so the test asserts both
# directions on the same flavor.
RSpec.describe "flat scalar serialization of degenerate components" do
  describe "edition" do
    # IEC's edition is degenerate by construction: iec/builder.rb has a single
    # construction site and it sets `number` and nothing else. Measured over
    # all 12,331 parseable IEC fixtures, 607 carry an edition and `number` is
    # the only field ever populated.
    it "flattens to a bare string when only number is set (IEC)" do
      hash = Pubid::Iec.parse("IEC 60038:2009 ED2").to_hash

      expect(hash["edition"]).to eq("2")
    end

    it "reads the flat form back (IEC)" do
      id = Pubid::Iec.parse("IEC 60038:2009 ED2")
      round_tripped = Pubid::Iec::Identifier.from_hash(id.to_hash)

      expect(round_tripped.edition).to be_a(Pubid::Components::Edition)
      expect(round_tripped.edition.number.to_s).to eq("2")
      expect(round_tripped.to_s).to eq(id.to_s)
      expect(round_tripped).to eq(id)
    end

    # A stored row written before the flattening must keep deserializing, or
    # every published relaton-data-iec row breaks at once.
    it "still reads the nested legacy form (IEC)" do
      legacy = Pubid::Iec.parse("IEC 60038:2009 ED2").to_hash
                         .merge("edition" => { "number" => "2" })

      expect(Pubid::Iec::Identifier.from_hash(legacy).edition.number.to_s)
        .to eq("2")
    end

    # ISO populates original_text as well ("Ed 13"), so the component is not
    # degenerate and must keep its hash — otherwise the spelling is lost.
    it "keeps the nested form when a sibling is set (ISO)" do
      hash = Pubid::Iso.parse("ISO/IEC DIR 1 ISO SUP Ed 13").to_hash

      expect(hash["edition"]).to be_a(Hash)
      expect(hash["edition"]["original_text"]).to eq("Ed 13")
    end

    # NIST's edition is a different class entirely, with type/id/original_prefix.
    it "keeps the nested form for a multi-field component (NIST)" do
      hash = Pubid::Nist.parse("NBS BMS 140e2").to_hash

      expect(hash["edition"]).to be_a(Hash)
      expect(hash["edition"]).to include("type" => "e", "id" => "2")
    end

    # Flavors that already declare `edition` as a plain :string must not move.
    it "leaves an already-flat edition unchanged (CCSDS)" do
      hash = Pubid::Ccsds.parse("CCSDS 121.0-B-2").to_hash

      expect(hash["edition"]).to eq("2")
    end
  end

  describe "date" do
    # CEN/CENELEC's `from_hash` raises before it reaches any date handling —
    # the pre-existing cross-flavor-type gap already pinned as
    # `cen_cenelec => 66` in spec/pubid/number_string_retype_spec.rb
    # (hand-off `bsi-set-cross-flavor-type`). Its `to_hash` half is asserted
    # normally below; only the read-back examples are pending. A pending that
    # starts passing turns red — that is the signal to delete this entry.
    PENDING_FROM_HASH = {
      "cen_cenelec" => "from_hash raises on the pre-existing cross-flavor " \
                       "type gap, before any date handling",
    }.freeze

    {
      "bsi" => "BS A 109:2024",
      "cen_cenelec" => "CR 13933:2000",
      "idf" => "IDF 146:2003 / AMD 1:2023",
    }.each do |flavor_name, ref|
      it "flattens a year-only date to a bare year (#{flavor_name})" do
        hash = Pubid::Registry.get(flavor_name).parse(ref).to_hash

        expect(hash).not_to have_key("date")
        expect(hash["year"]).to match(/\A\d{4}\z/)
      end

      it "reads the flat year back (#{flavor_name})" do
        pending(PENDING_FROM_HASH[flavor_name]) if PENDING_FROM_HASH[flavor_name]

        mod = Pubid::Registry.get(flavor_name)
        id = mod.parse(ref)

        expect(mod::Identifier.from_hash(id.to_hash).to_s).to eq(id.to_s)
      end

      it "still reads the nested legacy date (#{flavor_name})" do
        pending(PENDING_FROM_HASH[flavor_name]) if PENDING_FROM_HASH[flavor_name]

        mod = Pubid::Registry.get(flavor_name)
        id = mod.parse(ref)
        # The identifier's OWN date, not its root's: an IDF amendment carries
        # 2023 while the standard it amends carries 2003.
        year = id.date.year

        legacy = id.to_hash.reject { |k, _| k == "year" }
                   .merge("date" => { "year" => year })

        expect(mod::Identifier.from_hash(legacy).to_s).to eq(id.to_s)
      end
    end

    # The reason the rule is per identifier. IEC already serializes its date
    # flat, and these forms prove the flat path does not swallow the precision.
    it "keeps the month when one is present (IEC)" do
      hash = Pubid::Iec.parse("IEC CA 01:2025-10").to_hash

      expect(hash["year"]).to eq("2025")
      expect(hash["month"]).to eq("10")
    end

    it "keeps the undated marker (IEC)" do
      hash = Pubid::Iec.parse("IEC 60050:--").to_hash

      expect(hash["undated"]).to be(true)
    end
  end

  # The canonical-hash invariant CLAUDE.md records: relaton-index validates a
  # stored row with exactly this equality, so the flattening must be
  # idempotent, not merely correct once.
  describe "round-trip idempotence" do
    {
      "iec" => "IEC 60038:2009 ED2",
      "iso" => "ISO/IEC DIR 1 ISO SUP Ed 13",
      "nist" => "NBS BMS 140e2",
      "bsi" => "BS A 109:2024",
      "idf" => "IDF 146:2003 / AMD 1:2023",
    }.each do |flavor_name, ref|
      it "#{flavor_name}: from_hash(to_hash).to_hash == to_hash" do
        mod = Pubid::Registry.get(flavor_name)
        hash = mod.parse(ref).to_hash

        expect(mod::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end
end
