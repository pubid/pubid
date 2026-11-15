# frozen_string_literal: true

require "spec_helper"

# pubid#733 — the IEC typed-stage registry aligns with IEC's own stage-code
# correspondence table (IEC/ISO Harmonized APIs, section 3 "IEC/ISO Stage
# Code correspondance"; identical in v0.0.7 2021-05 and v0.0.8 2023-06,
# extracted at data/iec/stage-codes.md):
#
# - CDPAS is PAS's 50.20 row ("Draft circulated as DPAS"), not a
#   committee-draft state — the fabricated 30.xx row is gone and the
#   duplicate fold on the DPAS row's abbr list with it.
# - The TR ladder's point spellings (ADTR/CDTR/DTRM/NDTR) and the TS
#   ladder's (ADTS/CDTS/DTSM/NDTS) are rows of their own, each with the
#   exact code the table gives it — they no longer fold onto the 50.00
#   ladder rows, so the official URN's stage slot
#   (`harmonized_stages.first`) carries the table's code per spelling.
# - Plain DTR/DTS keep the folded 50.00 ladder (the registration step) and
#   DPAS is unchanged.
#
# The render keeps the parsed spelling per row (each row's canonical
# abbreviation is `abbr.first`), matching the #191/#193 pattern where the
# row's own spelling renders.

# (input, type key, stage code, official-URN stage slot). The official
# URN slot is `stage-{harmonized_stages.first}` of the row the spelling
# decodes to.
POINT_ROWS = [
  ["IEC CDPAS 60038", :pas, :cdpas, "pas-stage-50.20"],
  ["IEC ADTR 60038", :tr, :adtr, "tr-stage-40.99"],
  ["IEC CDTR 60038", :tr, :cdtr, "tr-stage-50.20"],
  ["IEC NDTR 60038", :tr, :ndtr, "tr-stage-50.92"],
  ["IEC DTRM 60038", :tr, :dtrm, "tr-stage-50.92"],
  ["IEC ADTS 60038", :ts, :adts, "ts-stage-40.99"],
  ["IEC CDTS 60038", :ts, :cdts, "ts-stage-50.20"],
  ["IEC NDTS 60038", :ts, :ndts, "ts-stage-50.92"],
  ["IEC DTSM 60038", :ts, :dtsm, "ts-stage-50.92"],
].freeze

TYPE_CLASSES = {
  pas: :PubliclyAvailableSpecification,
  tr: :TechnicalReport,
  ts: :TechnicalSpecification,
}.freeze

RSpec.describe "IEC typed-stage point codes (pubid#733)" do
  POINT_ROWS.each do |input, type_key, stage_code, slot|
    describe input do
      subject(:id) { Pubid::Iec.parse(input) }

      it "parses to the #{type_key.upcase} identifier" do
        expect(id).to be_a(Pubid::Iec::Identifiers.const_get(
                             TYPE_CLASSES[type_key],
                           ))
      end

      it "keeps the parsed spelling in the render" do
        expect(id.to_s).to eq(input)
      end

      it "carries its own typed-stage row (#{stage_code})" do
        expect(id.typed_stage.code.to_s).to eq(stage_code.to_s)
        expect(id.typed_stage.abbr.map(&:to_s)).to eq([stage_code.to_s.upcase])
      end

      it "emits the correspondence table's code in the official URN slot" do
        expect(id.to_urn).to eq("urn:iec:std:iec:60038::#{slot}::")
      end

      it "carries the row's own code in the pubid-scheme URN" do
        expect(id.to_pubid_urn)
          .to eq("urn:pubid:iec:#{type_key}:60038:stage-#{stage_code}")
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end

      it "round-trips through the render" do
        expect(Pubid::Iec.parse(id.to_s)).to eq(id)
      end
    end
  end

  # IEC's table gives two TR spellings and two TS spellings the same
  # rejection code 50.92. The official-URN slot is the same for the pair
  # (the slot is the harmonized code — that is what the #189/#733
  # alignment targets); the pubid-scheme URN distinguishes them, and the
  # official-URN reverse lookup resolves the FIRST row of the pair
  # (DTRM / DTSM — row order follows the correspondence table).
  describe "the shared 50.92 slot" do
    it "gives the rejected pair the same official URN" do
      expect(Pubid::Iec.parse("IEC NDTR 60038").to_urn)
        .to eq(Pubid::Iec.parse("IEC DTRM 60038").to_urn)
      expect(Pubid::Iec.parse("IEC NDTS 60038").to_urn)
        .to eq(Pubid::Iec.parse("IEC DTSM 60038").to_urn)
    end

    it "keeps the pair distinct in the pubid-scheme URN" do
      expect(Pubid::Iec.parse("IEC NDTR 60038").to_pubid_urn)
        .not_to eq(Pubid::Iec.parse("IEC DTRM 60038").to_pubid_urn)
      expect(Pubid::Iec.parse("IEC NDTS 60038").to_pubid_urn)
        .not_to eq(Pubid::Iec.parse("IEC DTSM 60038").to_pubid_urn)
    end

    it "decodes the shared slot to the first row of the pair" do
      expect(Pubid::Iec.parse_urn("urn:iec:std:iec:60038::tr-stage-50.92::")
        .typed_stage.code.to_s).to eq("dtrm")
      expect(Pubid::Iec.parse_urn("urn:iec:std:iec:60038::ts-stage-50.92::")
        .typed_stage.code.to_s).to eq("dtsm")
    end
  end

  # Plain DTR/DTS/DPAS keep their pre-split surfaces byte for byte.
  describe "the plain ladder rows are unchanged" do
    {
      "IEC DTR 60038" => "urn:iec:std:iec:60038::tr-stage-50.00::",
      "IEC DTS 60038" => "urn:iec:std:iec:60038::ts-stage-50.00::",
      "IEC DPAS 60038" => "urn:iec:std:iec:60038::pas-stage-50.00::",
    }.each do |input, official_urn|
      describe input do
        subject(:id) { Pubid::Iec.parse(input) }

        it "renders unchanged" do
          expect(id.to_s).to eq(input)
        end

        it "keeps the 50.00 registration slot in the official URN" do
          expect(id.to_urn).to eq(official_urn)
        end

        it "keeps the ladder row's folded harmonized stages" do
          expect(id.typed_stage.harmonized_stages.map(&:to_s))
            .to eq(%w[50.00 50.20 50.60 50.92 50.98 50.99])
        end

        it "round-trips through the render" do
          expect(Pubid::Iec.parse(id.to_s)).to eq(id)
        end
      end
    end

    it "DPAS no longer folds CDPAS onto its abbr list" do
      expect(Pubid::Iec.locate_stage("DPAS").abbr.map(&:to_s)).to eq(["DPAS"])
    end

    it "DTR/DTS no longer fold the point spellings" do
      expect(Pubid::Iec.locate_stage("DTR").abbr.map(&:to_s)).to eq(%w[DTR])
      expect(Pubid::Iec.locate_stage("DTS").abbr.map(&:to_s)).to eq(%w[DTS])
    end
  end

  # The registry lookups the correspondence-table consumers use resolve
  # each spelling to its own row now.
  describe "registry lookups" do
    it "resolves CDPAS to the 50.20 row" do
      stage = Pubid::Iec.locate_stage("CDPAS")
      expect(stage.code.to_s).to eq("cdpas")
      expect(stage.harmonized_stages.map(&:to_s)).to eq(["50.20"])
    end

    it "resolves every point spelling to its own row" do
      POINT_ROWS.each do |input, type_key, stage_code, _|
        abbr = input.split[1]
        stage = Pubid::Iec.locate_stage(abbr)
        expect(stage.code.to_s).to eq(stage_code.to_s)
        expect(stage.type_code.to_s).to eq(type_key.to_s)
      end
    end

    it "resolves the harmonized-code lookups the reconciliation pins" do
      # 40.99 still belongs to cdv (IS family, pubid#570's rule); the IS
      # ladder still owns 50.20 and 50.92 through fdis.
      expect(Pubid::Iec.locate_stage_by_harmonized_code("40.99").code.to_s)
        .to eq("cdv")
      expect(Pubid::Iec.locate_stage_by_harmonized_code("50.20").code.to_s)
        .to eq("fdis")
      expect(Pubid::Iec.locate_stage_by_harmonized_code("50.92").code.to_s)
        .to eq("fdis")
    end
  end
end
