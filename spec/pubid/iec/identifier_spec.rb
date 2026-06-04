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
  end
end
