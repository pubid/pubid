# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iec"

RSpec.describe "IEC Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      hash = id.to_h

      expect(hash[:flavor]).to eq("iec")
      expect(hash[:publisher]).to eq("IEC")
      # IEC uses a custom Code component, so number might be serialized differently
      expect(hash[:year]).to eq("2011")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("iec")
      expect(parsed["year"]).to eq("2011")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      mr_string = id.to_mr_string
      # IEC MR string format includes year
      expect(mr_string).to include("IEC")
      expect(mr_string).to include("2011")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "iec",
        publisher: "IEC",
        number: "60050",
        year: "2011"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"iec","publisher":"IEC","number":"60050","year":"2011"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end

  describe ".from_mr_string" do
    it "creates identifier from MR string" do
      mr_string = "IEC.60050.2011"

      id = Pubid::Serializable.from_mr_string(mr_string)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end

  # Compound identifiers (consolidated, VAP, sheet, fragment) wrap a base
  # identifier that does not have a `.code` attribute. Before the fix these
  # wrappers defined a `def code` delegation; Serializable#extract_number
  # detected it via `respond_to?(:code)` and then crashed inside
  # lutaml-model's method_missing when the delegate had no `.code`.
  describe "compound identifier serialization (Harmonized API inputs)" do
    {
      "IEC 60529:1989+AMD1:1999 CSV/COR2:2007" => "Corrigendum",
      "CISPR TR 16-3:2000+AMD1:2002 CSV" => "VapIdentifier",
      "IEC/ASTM 62885-6:2018" => "InternationalStandard",
    }.each do |input, expected_class_suffix|
      context input do
        let(:id) { Pubid::Iec.parse(input) }

        it "parses to the expected class" do
          expect(id.class.name).to end_with(expected_class_suffix)
        end

        it "round-trips via to_s" do
          expect(id.to_s).to eq(input)
        end

        it "serializes to_h without raising" do
          expect { id.to_h }.not_to raise_error
        end

        it "serializes to_yaml without ruby/object markers" do
          expect(id.to_h.to_yaml).not_to include("ruby/object")
        end
      end
    end
  end
end
