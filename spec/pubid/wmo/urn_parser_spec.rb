# frozen_string_literal: true

require "spec_helper"

# The MRN URN forms (the IALA-pattern proposed shape of pubid#763; no
# authoritative WMO urn:mrn:wmo: rule is published, so the generator and
# the parser define the namespace's extension).
RSpec.describe Pubid::Wmo::UrnParser do
  describe ".parse" do
    {
      "urn:mrn:wmo:pub:wmo-1364" => "WMO-No. 1364",
      "urn:mrn:wmo:pub:wmo-1364:ed2025" => "WMO-No. 1364, 2025 edition",
      "urn:mrn:wmo:pub:s-411" => "S-411",
      "urn:mrn:wmo:pub:s-411:ed1.2.1" => "S-411 1.2.1",
      "urn:mrn:wmo:pub:s-411:annex-a" => "S-411 Annex A",
      "urn:mrn:wmo:pub:s-411:annex" => "S-411 Annex",
    }.each do |urn, canonical|
      it "parses #{urn.inspect} → #{canonical.inspect}" do
        expect(described_class.parse(urn).to_s).to eq(canonical)
      end
    end

    [
      "urn:mrn:wmo:pub:x-1",                     # unknown code segment
      "urn:mrn:wmo:pub:s-411:junk",              # unknown segment
      "urn:mrn:wmo:pub:s-411:ed9",               # not dotted
      "urn:mrn:wmo:pub:wmo-1364:ed1.2.1",        # not a year
      "urn:mrn:wmo:pub:s-411:annex-a:annex-b",   # duplicate annex
      "urn:wmo:s-411",                           # not the mrn namespace
      "urn:mrn:wmo:lib:s-411",                   # not the pub sub-namespace
    ].each do |urn|
      it "rejects #{urn.inspect}" do
        expect { described_class.parse(urn) }
          .to raise_error(Pubid::Errors::UrnParseError)
      end
    end

    it "rejects a non-String" do
      expect { described_class.parse(nil) }
        .to raise_error(Pubid::Errors::InvalidInputError)
    end
  end
end
