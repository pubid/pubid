# frozen_string_literal: true

require "spec_helper"

# ITU-R Resolutions (https://www.itu.int/pub/R-RES/en) are adopted by the
# Radiocommunication Assembly and revised in place: "Resolution ITU-R 1-9" is
# revision 9 of Resolution 1, dated 2023 on ITU's page id R-RES-R.1-9-2023.
#
# relaton-data-itu used to store them as "ITU-R R.1-9", which pubid reads as a
# Recommendation of series R. That legacy spelling keeps parsing as it did, so
# the published index rows stay valid until the data repo re-crawls.
RSpec.describe Pubid::Itu::Identifiers::Resolution do
  def parse(str) = Pubid::Itu.parse(str)

  describe "parsing" do
    it "parses ITU's own citation form" do
      id = parse("Resolution ITU-R 1-9")

      expect(id).to be_a(described_class)
      expect(id.sector.to_s).to eq("R")
      expect(id.series).to be_nil
      expect(id.code.number.to_s).to eq("1")
      expect(id.code.parts.map(&:to_s)).to eq(["9"])
      expect(id.date).to be_nil
    end

    it "parses an undated resolution with no revision" do
      id = parse("Resolution ITU-R 1")

      expect(id).to be_a(described_class)
      expect(id.code.number.to_s).to eq("1")
      expect(id.code.parts).to be_empty
    end

    it "parses a dated revision" do
      id = parse("Resolution ITU-R 1-9 (2023)")

      expect(id.date.year.to_s).to eq("2023")
      expect(id.date.month).to be_nil
    end

    %w[ITU-R\ Res.\ 1-9 ITU-R\ Resolution\ 1-9 Res.\ ITU-R\ 1-9].each do |input|
      it "parses the spelling #{input.inspect} as the same document" do
        expect(parse(input)).to eq(parse("Resolution ITU-R 1-9"))
      end
    end

    it "parses a language-suffixed resolution" do
      expect(parse("Resolution ITU-R 1-9-F").language).to eq("F")
    end
  end

  describe "rendering" do
    {
      "Resolution ITU-R 1-9" => "Resolution ITU-R 1-9",
      "Resolution ITU-R 1" => "Resolution ITU-R 1",
      "Resolution ITU-R 1-9 (2023)" => "Resolution ITU-R 1-9 (2023)",
      "ITU-R Res. 1-9" => "Resolution ITU-R 1-9",
      "ITU-R Resolution 1-9 (2023)" => "Resolution ITU-R 1-9 (2023)",
    }.each do |input, expected|
      it "renders #{input.inspect} as #{expected.inspect}" do
        expect(parse(input).to_s).to eq(expected)
      end
    end
  end

  describe "serialization" do
    let(:resolution) { parse("Resolution ITU-R 1-9 (2023)") }
    let(:hash) { resolution.to_hash }

    it "is flat and carries its own polymorphic type" do
      expect(hash).to eq(
        "_type" => "pubid:itu:resolution",
        "sector" => "R",
        "number" => "1",
        "parts" => ["9"],
        "year" => "2023",
      )
    end

    it "round-trips through from_hash losslessly" do
      restored = Pubid::Itu::Identifier.from_hash(hash)

      expect(restored).to be_a(described_class)
      expect(restored.to_hash).to eq(hash)
      expect(restored.to_s).to eq(resolution.to_s)
      expect(restored).to eq(resolution)
    end

    it "round-trips through Pubid.from_hash" do
      expect(Pubid.from_hash(hash)).to eq(resolution)
    end

    it "exposes the resolution number as root.number" do
      expect(resolution.root.number.to_s).to eq("1")
    end
  end

  describe "matching" do
    let(:reference) { parse("Resolution ITU-R 1") }

    it "finds every revision when the parts are ignored" do
      %w[1-1 1-5 1-9].each do |rev|
        candidate = parse("Resolution ITU-R #{rev} (2023)")

        expect(reference.matches?(candidate, ignore: %i[parts year]))
          .to be(true), rev
      end
    end

    it "does not match a different number with the same leading digit" do
      expect(reference.matches?(parse("Resolution ITU-R 10"),
                                ignore: %i[parts year])).to be false
    end

    it "tells revisions apart when nothing is ignored" do
      expect(parse("Resolution ITU-R 1-9"))
        .not_to eq(parse("Resolution ITU-R 1-8"))
    end
  end

  describe "distinctness from a Recommendation of the same number" do
    let(:resolution) { parse("Resolution ITU-R 1-9") }
    let(:recommendation) { parse("ITU-R 1-9") }

    it "compares unequal in both directions" do
      expect(recommendation).to be_a(Pubid::Itu::Identifiers::Recommendation)
      expect(resolution).not_to eq(recommendation)
      expect(recommendation).not_to eq(resolution)
    end

    it "is not a subset match in either direction" do
      expect(resolution === recommendation).to be false
      expect(recommendation === resolution).to be false
    end

    it "cannot be resolved to one another by #matches?" do
      expect(resolution.matches?(recommendation, ignore: %i[year])).to be false
      expect(recommendation.matches?(resolution, ignore: %i[year])).to be false
    end

    it "renders, URNs and slugs differently" do
      expect(resolution.to_s).not_to eq(recommendation.to_s)
      expect(resolution.to_urn).not_to eq(recommendation.to_urn)
      expect(resolution.to_mr_string).not_to eq(recommendation.to_mr_string)
      expect(resolution.to_pubid_urn).not_to eq(recommendation.to_pubid_urn)
    end
  end

  describe "URN and MR string" do
    let(:resolution) { parse("Resolution ITU-R 1-9 (2023)") }

    it "marks the resolution in the URN" do
      expect(resolution.to_urn).to eq("urn:itu:r:resolution:1-9:2023")
    end

    it "parses back from its URN" do
      expect(Pubid::Itu::UrnParser.parse("urn:itu:r:resolution:1-9"))
        .to eq(parse("Resolution ITU-R 1-9"))
    end

    it "marks the resolution in the MR string" do
      expect(parse("Resolution ITU-R 1-9").to_mr_string)
        .to eq("itu.r.resolution.1-9")
    end

    it "round-trips through the pubid-scheme URN" do
      expect(Pubid.parse_urn(resolution.to_pubid_urn).to_hash)
        .to eq(resolution.to_hash)
    end
  end

  # PREFIXES stays ["ITU"] (the Report ruling), so top-level routing finds
  # the canonical form by its exact round trip and the infix form by the
  # ITU prefix. "Res. ITU-R 1-9" has neither and does not route; use
  # Pubid::Itu.parse for it.
  describe "Pubid.parse routing" do
    it "routes the canonical and the infix spelling to ITU" do
      ["Resolution ITU-R 1-9 (2023)", "ITU-R Res. 1-9"].each do |input|
        expect(Pubid.parse(input)).to be_a(described_class), input
      end
    end

    it "does not route the leading abbreviated spelling" do
      expect { Pubid.parse("Res. ITU-R 1-9") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  # relaton-data-itu stores its 245 resolution rows as "ITU-R R.<n>"; they
  # must keep parsing, unchanged, until the data repo re-crawls.
  describe "backwards compatibility" do
    it "leaves the legacy series-R spelling a Recommendation" do
      id = parse("ITU-R R.1-9")

      expect(id).to be_a(Pubid::Itu::Identifiers::Recommendation)
      expect(id.to_hash).to eq(
        "_type" => "pubid:itu:recommendation",
        "sector" => "R",
        "series" => "R",
        "number" => "1",
        "parts" => ["9"],
      )
      expect(id.to_s).to eq("ITU-R R.1-9")
    end

    it "leaves a bare numeric identifier a Recommendation" do
      expect(parse("ITU-R 1-9"))
        .to be_a(Pubid::Itu::Identifiers::Recommendation)
    end

    it "rejects a series on a resolution" do
      expect { parse("Resolution ITU-R BT.1") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end
end
