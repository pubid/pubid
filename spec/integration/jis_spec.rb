# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/jis"

RSpec.describe "JIS Integration" do
  describe "parsing and rendering" do
    shared_examples "parses and renders correctly" do |input, expected_output = nil|
      it "parses and renders #{input}" do
        expected = expected_output || input
        identifier = PubidNew::Jis.parse(input)
        expect(identifier.to_s).to eq(expected)
      end
    end

    context "basic standards" do
      include_examples "parses and renders correctly", "JIS A 0001:1999"
      include_examples "parses and renders correctly", "JIS B 0001:2019"
      include_examples "parses and renders correctly", "JIS C 0303:2000"
    end

    context "without year" do
      include_examples "parses and renders correctly", "JIS A 0001"
      include_examples "parses and renders correctly", "JIS B 0060"
    end

    context "with parts" do
      include_examples "parses and renders correctly", "JIS A 1129-1:2010"
      include_examples "parses and renders correctly", "JIS B 0060-1:2015"
      include_examples "parses and renders correctly", "JIS C 61000-3-2:2019"
    end

    context "with language" do
      include_examples "parses and renders correctly", "JIS Z 8301:2019(E)"
      include_examples "parses and renders correctly", "JIS Z 8301:2019(J)"
    end

    context "all-parts notation" do
      include_examples "parses and renders correctly", "JIS C 0617（規格群）"
      include_examples "parses and renders correctly", "JIS B 0060（規格群）"
    end

    context "technical reports" do
      include_examples "parses and renders correctly", "JIS TR Z 8301:2019"
      include_examples "parses and renders correctly", "JIS TR B 0035:2019"
      include_examples "parses and renders correctly", "JIS/TR X 0005:1998", "JIS TR X 0005:1998"
      include_examples "parses and renders correctly", "TR B 0035:2019", "JIS TR B 0035:2019"
    end

    context "technical specifications" do
      include_examples "parses and renders correctly", "JIS TS Z 8301:2019"
      include_examples "parses and renders correctly", "JIS TS Z 0030-1:2017"
      include_examples "parses and renders correctly", "TS Z0030-1:2017", "JIS TS Z 0030-1:2017"
    end

    context "amendments" do
      include_examples "parses and renders correctly", "JIS A 0001:1999/AMD 1:2000"
      include_examples "parses and renders correctly", "JIS X 0208:1997/AMENDMENT 1:2012", "JIS X 0208:1997/AMD 1:2012"
    end

    context "explanations" do
      include_examples "parses and renders correctly", "JIS K 2151:2004/EXPL"
      include_examples "parses and renders correctly", "JIS K 2249-4:2011/EXPL 4"
      include_examples "parses and renders correctly", "JIS K 2249-4:2011/EXPLANATION 4", "JIS K 2249-4:2011/EXPL 4"
    end

    context "Japanese characters" do
      include_examples "parses and renders correctly", "JIS　B　0001", "JIS B 0001"
      include_examples "parses and renders correctly", "JIS C 61000ｰ3ｰ2", "JIS C 61000-3-2"
      include_examples "parses and renders correctly", "JIS C 61000-3-2：2011", "JIS C 61000-3-2:2011"
      include_examples "parses and renders correctly", "JISX0902-1:2019", "JIS X 0902-1:2019"
      include_examples "parses and renders correctly", "JISX0836:2005", "JIS X 0836:2005"
    end

    context "without publisher prefix" do
      include_examples "parses and renders correctly", "B 0001", "JIS B 0001"
      include_examples "parses and renders correctly", "A 0001:1999", "JIS A 0001:1999"
    end
  end

  describe "all_parts comparison" do
    it "matches identifiers with same series and number regardless of year/part" do
      all_parts_id = PubidNew::Jis.parse("JIS C 0617（規格群）")
      specific_id = PubidNew::Jis.parse("JIS C 0617-2:2017")

      expect(all_parts_id).to eq(specific_id)
      expect(specific_id).to eq(all_parts_id)
    end

    it "does not match identifiers with different series" do
      all_parts_id = PubidNew::Jis.parse("JIS C 0617（規格群）")
      different_id = PubidNew::Jis.parse("JIS C 0618-1")

      expect(all_parts_id).not_to eq(different_id)
    end
  end

  describe "parsing all fixtures" do
    it "parses all identifiers from jis-pubids.txt" do
      fixture_file = File.join(__dir__, "../fixtures/jis/identifiers/full/international_standard.txt")

      File.readlines(fixture_file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        expect {
          identifier = PubidNew::Jis.parse(line)
          expect(identifier.to_s.upcase).to eq(line.upcase)
        }.not_to raise_error, "Failed to parse: #{line}"
      end
    end
  end
end