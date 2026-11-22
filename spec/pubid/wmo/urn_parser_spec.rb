# frozen_string_literal: true

require "spec_helper"

# The MRN URN forms (the IALA-pattern proposed shape of pubid#763, widened
# with the TD/JCOMM/GAW slugs, the volume/status/updated segments and the
# hyphenated year pair; no authoritative WMO urn:mrn:wmo: rule is
# published, so the generator and the parser define the namespace's
# extension).
RSpec.describe Pubid::Wmo::UrnParser do
  describe ".parse" do
    {
      "urn:mrn:wmo:pub:wmo-1364" => "WMO-No. 1364",
      "urn:mrn:wmo:pub:wmo-1364:ed2025" => "WMO-No. 1364, 2025 edition",
      "urn:mrn:wmo:pub:s-411" => "S-411",
      "urn:mrn:wmo:pub:s-411:ed1.2.1" => "S-411 1.2.1",
      "urn:mrn:wmo:pub:s-411:annex-a" => "S-411 Annex A",
      "urn:mrn:wmo:pub:s-411:annex" => "S-411 Annex",
      # the widening
      "urn:mrn:wmo:pub:wmo-td-196" => "WMO/TD-No. 196",
      "urn:mrn:wmo:pub:wmo-td-1086" => "WMO/TD-No. 1086",
      "urn:mrn:wmo:pub:jcomm-tr-14" => "JCOMM Technical Report No. 14",
      "urn:mrn:wmo:pub:gaw-312" => "GAW Report No. 312",
      "urn:mrn:wmo:pub:wmo-306:vol-i.1" => "WMO-No. 306, Volume I.1",
      "urn:mrn:wmo:pub:wmo-9:vol-d" => "WMO-No. 9, Volume D",
      "urn:mrn:wmo:pub:wmo-306:vol-i.1:ed2020" =>
        "WMO-No. 306, Volume I.1, 2020 edition",
      "urn:mrn:wmo:pub:wmo-8:ed2021-2018" => "WMO-No. 8, 2021/2018 edition",
      "urn:mrn:wmo:pub:wmo-8:status-provisional:ed2026" =>
        "WMO-No. 8, Provisional 2026 edition",
      "urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025" =>
        "WMO-No. 1364, 2023 edition, updated in 2025",
    }.each do |urn, canonical|
      it "parses #{urn.inspect} → #{canonical.inspect}" do
        expect(described_class.parse(urn).to_s).to eq(canonical)
      end
    end

    it "keeps the td slug off the bare wmo- code (longest match first)" do
      expect(described_class.parse("urn:mrn:wmo:pub:wmo-td-196").series)
        .to eq("TD")
      expect(described_class.parse("urn:mrn:wmo:pub:wmo-196").series)
        .to be_nil
    end

    [
      "urn:mrn:wmo:pub:x-1",                     # unknown code segment
      "urn:mrn:wmo:pub:s-411:junk",              # unknown segment
      "urn:mrn:wmo:pub:s-411:ed9",               # not dotted
      "urn:mrn:wmo:pub:wmo-1364:ed1.2.1",        # not a year
      "urn:mrn:wmo:pub:s-411:annex-a:annex-b",   # duplicate annex
      "urn:wmo:s-411",                           # not the mrn namespace
      "urn:mrn:wmo:lib:s-411",                   # not the pub sub-namespace
      # the widening rejects
      "urn:mrn:wmo:pub:wmo-td-196:vol-3",        # arabic volume
      "urn:mrn:wmo:pub:wmo-td-196:vol",          # valueless volume
      "urn:mrn:wmo:pub:wmo-1364:ed2021-2018-x",  # malformed pair
      "urn:mrn:wmo:pub:wmo-1364:updated-25",     # not a year
      "urn:mrn:wmo:pub:wmo-td-196:vol-a:vol-b",  # duplicate volume
      "urn:mrn:wmo:pub:wmo-8:status-provisional:status-final",
      "urn:mrn:wmo:pub:wmo-8:ed2026:ed2027",     # duplicate edition
      "urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025:updated-2026",
      "urn:mrn:wmo:pub:td-196",                  # unprefixed TD slug
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
