# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iec::Identifier do
  describe ".parse" do
    it "parses a basic identifier" do
      # Basic smoke test to verify parsing works
      # TODO: Add more comprehensive tests with flavor-specific identifiers
      expect(described_class).to respond_to(:parse)
    end

    context "with ISO/IEC Directives" do
      # These are parsed as a flat InternationalStandard number (no
      # part/subpart) so they round-trip to the input and class-match the
      # IEC index rows that relaton-iec relies on.
      directives = [
        "ISO/IEC DIR",
        "ISO/IEC DIR 1",
        "ISO/IEC DIR 1 IEC SUP",
        "ISO/IEC DIR 2 IEC",
        "ISO/IEC DIR IEC SUP",
      ]

      directives.each do |id_str|
        it "round-trips #{id_str.inspect}" do
          parsed = described_class.parse(id_str)
          expect(parsed).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
          expect(parsed.to_s).to eq(id_str)
        end
      end
    end

    # Issue #138: undated references (ISO/IEC convention)
    context "with undated reference" do
      it "parses IEC 60050:-- and round-trips via to_s" do
        id = described_class.parse("IEC 60050:--")
        expect(id.date.undated?).to be true
        expect(id.date.year).to be_nil
        expect(id.to_s).to eq("IEC 60050:--")
      end

      it "parses IEC 60050:— (em-dash) and canonicalizes to double-dash" do
        id = described_class.parse("IEC 60050:—")
        expect(id.date.undated?).to be true
        # Canonical presentation form is the double-dash, per issue #138.
        expect(id.to_s).to eq("IEC 60050:--")
      end

      it "preserves the undated flag through to_hash / from_hash round-trip" do
        id = described_class.parse("IEC 60050:--")
        rebuilt = described_class.from_hash(id.to_hash)
        expect(rebuilt.date.undated?).to be true
        expect(rebuilt.to_s).to eq("IEC 60050:--")
      end

      it "keeps the date slot in the URN for undated references (issue #138)" do
        id = described_class.parse("IEC 60050:--")
        # IEC's positional URN keeps every slot; the undated marker renders
        # as `--` in the date position rather than dropping the slot.
        expect(id.to_urn).to eq("urn:iec:std:iec:60050:--:::")
      end
    end
  end
end
