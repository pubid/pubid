# frozen_string_literal: true

require "spec_helper"

# "FIPS PUB <number>" is the FIPS series' own printed face (document cover
# and NIST catalogue style), but the grammar reads only the canonical
# "NIST FIPS <number>" / "FIPS <number>" spellings and threw at the "PUB"
# token (pubid#697, field-reported via metanorma/metanorma-pdfa#114). The
# preprocessor's alias rewrites the printed prefix onto the canonical face,
# so a printed-form parse lands on exactly the model the canonical parse
# builds: same to_hash, same render, same URN, same MR string.
RSpec.describe "NIST FIPS PUB printed-form alias" do
  describe "the basic printed form" do
    it "parses FIPS PUB 205 as FederalInformationProcessingStandards" do
      id = Pubid::Nist::Identifier.parse("FIPS PUB 205")

      expect(id).to be_a(Pubid::Nist::Identifiers::FederalInformationProcessingStandards)
      expect(id.publisher.to_s).to eq("NIST")
      expect(id.series.to_s).to eq("FIPS")
      expect(id.number).to eq("205")
    end

    it "renders canonically" do
      expect(Pubid::Nist::Identifier.parse("FIPS PUB 205").to_s)
        .to eq("NIST FIPS 205")
    end

    it "hash-matches the canonical NIST FIPS parse" do
      printed = Pubid::Nist::Identifier.parse("FIPS PUB 205")
      canonical = Pubid::Nist::Identifier.parse("NIST FIPS 205")

      expect(printed.to_hash).to eq(canonical.to_hash)
    end

    it "matches the canonical parse on every identity surface" do
      printed = Pubid::Nist::Identifier.parse("FIPS PUB 205")
      canonical = Pubid::Nist::Identifier.parse("NIST FIPS 205")

      expect(printed.to_s).to eq(canonical.to_s)
      expect(printed.to_urn).to eq(canonical.to_urn)
      expect(printed.to_mr_string).to eq(canonical.to_mr_string)
    end
  end

  describe "hyphenated numbers" do
    it "parses FIPS PUB 180-4 (revision folded into the number)" do
      id = Pubid::Nist::Identifier.parse("FIPS PUB 180-4")

      expect(id.number).to eq("180-4")
      expect(id.to_s).to eq("NIST FIPS 180-4")
    end
  end

  describe "the revision forms the grammar models" do
    it "parses FIPS PUB 199 Rev. 1 and hash-matches the canonical parse" do
      printed = Pubid::Nist::Identifier.parse("FIPS PUB 199 Rev. 1")
      canonical = Pubid::Nist::Identifier.parse("NIST FIPS 199 Rev. 1")

      expect(printed.edition.type).to eq("r")
      expect(printed.edition.id).to eq("1")
      expect(printed.to_hash).to eq(canonical.to_hash)
      expect(printed.to_s).to eq(canonical.to_s)
    end

    it "parses FIPS PUB 140-3 rev1 (compact revision)" do
      id = Pubid::Nist::Identifier.parse("FIPS PUB 140-3 rev1")

      expect(id.edition.type).to eq("r")
      expect(id.edition.id).to eq("1")
      expect(id.to_s).to eq("NIST FIPS 140-3r1")
    end
  end

  describe "update and draft forms ride the alias" do
    it "parses FIPS PUB 197-upd1" do
      id = Pubid::Nist::Identifier.parse("FIPS PUB 197-upd1")

      expect(id.to_s).to eq("NIST FIPS 197/Upd1")
    end

    it "parses FIPS PUB 140-3 -draft 2" do
      id = Pubid::Nist::Identifier.parse("FIPS PUB 140-3 -draft 2")

      expect(id.draft_number).to eq("2")
      expect(id.to_s).to eq("NIST FIPS 140-3 2pd")
    end
  end

  describe "case and scope of the alias" do
    it "aliases the lowercase printed form" do
      expect(Pubid::Nist::Identifier.parse("fips pub 205").to_s)
        .to eq("NIST FIPS 205")
    end

    it "does not touch the bare FIPS series (no publisher was parsed)" do
      id = Pubid::Nist::Identifier.parse("FIPS 205")

      expect(id.to_s).to eq("FIPS 205")
      expect(id.publisher_was_parsed).to be(false)
    end

    it "does not touch NBS FIPS identifiers" do
      id = Pubid::Nist::Identifier.parse("NBS FIPS 1")

      expect(id.to_s).to eq("NBS FIPS 1")
      expect(id.publisher.to_s).to eq("NBS")
    end
  end
end
