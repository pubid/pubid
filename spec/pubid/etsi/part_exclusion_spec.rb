require "spec_helper"

RSpec.describe "ETSI part exclusion" do
  # ETSI keeps number + part inside one Code component, so exclude(:part) must
  # clear the part while keeping the number, letting a part-less reference match
  # all parts of a document via matches?(ignore: [..., :part]).

  describe "#exclude(:part)" do
    subject(:excluded) do
      Pubid::Etsi.parse("ETSI EN 300 175-1 V1.9.1 (2005-09)").exclude(:part)
    end

    it "clears the part but keeps the number" do
      expect(excluded.code.number).to eq("300 175")
      expect(excluded.code.parts).to eq([])
      expect(excluded.code.to_s).to eq("300 175")
    end

    it "accepts :parts as an alias" do
      also = Pubid::Etsi.parse("ETSI EN 300 175-1 V1.9.1 (2005-09)")
        .exclude(:parts)
      expect(also.code.parts).to eq([])
    end

    it "leaves a part-less identifier unchanged" do
      base = Pubid::Etsi.parse("ETSI EN 300 175")
      expect(base.exclude(:part).code.to_s).to eq("300 175")
    end
  end

  describe "#matches? ignoring the part" do
    let(:partless) { Pubid::Etsi.parse("ETSI EN 300 175") }
    let(:with_part) do
      Pubid::Etsi.parse("ETSI EN 300 175-1 V1.9.1 (2005-09)")
    end
    let(:other_doc) do
      Pubid::Etsi.parse("ETSI GS 300 176-1 V1.1.1 (2020-01)")
    end

    it "matches all parts when part/version/date are ignored" do
      expect(
        partless.matches?(with_part, ignore: %i[version date part]),
      ).to be true
    end

    it "still distinguishes a different type/number" do
      expect(
        partless.matches?(other_doc, ignore: %i[version date part]),
      ).to be false
    end

    it "does not match different parts when the part is NOT ignored" do
      part1 = Pubid::Etsi.parse("ETSI EN 300 175-1 V1.9.1 (2005-09)")
      part2 = Pubid::Etsi.parse("ETSI EN 300 175-2 V1.9.1 (2005-09)")
      expect(part1.matches?(part2, ignore: %i[version date])).to be false
      expect(part1.matches?(part2, ignore: %i[version date part])).to be true
    end
  end
end
