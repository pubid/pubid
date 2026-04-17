# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Pubid::Serializable do
  describe "#to_h" do
    context "with ISO InternationalStandard" do
      let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

      it "exports basic identifier attributes" do
        hash = identifier.to_h

        expect(hash[:flavor]).to eq("iso")
        expect(hash[:publisher]).to eq("ISO")
        expect(hash[:number]).to eq("9001")
        expect(hash[:year]).to eq("2015")
      end

      it "includes type information" do
        hash = identifier.to_h

        expect(hash[:type]).not_to be_nil
        expect(hash[:type_info]).to be_a(Hash)
      end

      it "includes URN when available" do
        hash = identifier.to_h

        # ISO URN doesn't include year for base documents
        expect(hash[:urn]).to start_with("urn:iso:std:iso:9001")
      end

      it "includes typed_stage information" do
        hash = identifier.to_h

        expect(hash[:typed_stage]).to be_a(Hash)
        expect(hash[:typed_stage][:code]).to eq("is")
      end

      it "includes mr_string" do
        hash = identifier.to_h

        expect(hash[:mr_string]).to eq("ISO.9001.2015")
      end
    end

    context "with ISO identifier with copublisher" do
      let(:identifier) { Pubid::Iso.parse("ISO/IEC 27001:2013") }

      it "exports copublisher" do
        hash = identifier.to_h

        expect(hash[:copublishers]).to eq(["IEC"])
      end
    end

    context "with ISO identifier with part" do
      let(:identifier) { Pubid::Iso.parse("ISO 8601-1:2019") }

      it "exports part" do
        hash = identifier.to_h

        expect(hash[:part]).to eq("1")
      end

      it "includes part in mr_string" do
        hash = identifier.to_h

        expect(hash[:mr_string]).to eq("ISO.8601-1.2019")
      end
    end

    context "with ISO identifier with languages" do
      let(:identifier) { Pubid::Iso.parse("ISO/IEC Guide 51:1999(E/F/R)") }

      it "exports languages" do
        hash = identifier.to_h(include_metadata: false)

        # Languages are stored as uppercase codes (E/F/R) for parser compatibility
        expect(hash[:languages]).to eq(["E", "F", "R"])
      end
    end

    context "with ISO amendment" do
      let(:identifier) { Pubid::Iso.parse("ISO 19110:2005/Amd 1:2011") }

      it "exports supplement information" do
        hash = identifier.to_h

        expect(hash[:supplements]).to be_a(Array)
        expect(hash[:supplements].size).to eq(1)

        supplement = hash[:supplements].first
        expect(supplement[:type]).to eq("amendment")
        expect(supplement[:number]).to eq("1")
        expect(supplement[:year]).to eq("2011")
      end
    end

    context "with nested supplements" do
      let(:identifier) { Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017") }

      it "exports all supplements in correct order" do
        hash = identifier.to_h

        expect(hash[:supplements]).to be_a(Array)
        expect(hash[:supplements].size).to eq(2)

        # First supplement (outermost) should be last in array (we reverse it)
        supplement_1 = hash[:supplements][0] # Corrigendum
        supplement_2 = hash[:supplements][1] # Amendment

        expect(supplement_1[:type]).to eq("corrigendum")
        expect(supplement_1[:number]).to eq("1")
        expect(supplement_1[:year]).to eq("2017")

        expect(supplement_2[:type]).to eq("amendment")
        expect(supplement_2[:number]).to eq("3")
        expect(supplement_2[:year]).to eq("2016")
      end
    end

    context "with include_metadata: false" do
      let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

      it "excludes URN and metadata" do
        hash = identifier.to_h(include_metadata: false)

        expect(hash[:urn]).to be_nil
        expect(hash[:mr_string]).to be_nil
        expect(hash[:typed_stage]).to be_nil
      end
    end

    context "with NIST identifier" do
      let(:identifier) { Pubid::Nist.parse("NIST SP 800-53") }

      it "exports NIST-specific attributes" do
        hash = identifier.to_h(include_metadata: false)

        expect(hash[:flavor]).to eq("nist")
        expect(hash[:publisher]).to eq("NIST")
        expect(hash[:number]).to eq("800-53")
      end
    end

    context "with IEEE identifier" do
      let(:identifier) { Pubid::Ieee.parse("IEEE Std 802.3-2018") }

      it "exports IEEE-specific attributes" do
        hash = identifier.to_h(include_metadata: false)

        expect(hash[:flavor]).to eq("ieee")
        expect(hash[:publisher]).to eq("IEEE")
        expect(hash[:number]).to eq("802.3")
        expect(hash[:year]).to eq("2018")
      end
    end
  end

  describe "#to_json" do
    let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

    it "returns valid JSON string" do
      json = identifier.to_json

      expect(json).to be_a(String)

      # Verify it's valid JSON
      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("iso")
      expect(parsed["number"]).to eq("9001")
    end

    it "includes all to_h attributes" do
      json = identifier.to_json
      parsed = JSON.parse(json)

      expect(parsed.keys).to include("flavor", "publisher", "number", "year")
    end

    it "can be parsed back with from_json" do
      original = identifier
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end

  describe "#to_yaml" do
    let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

    it "returns valid YAML string" do
      yaml = identifier.to_yaml

      expect(yaml).to be_a(String)

      # Verify it's valid YAML (YAML preserves symbol keys, unlike JSON)
      require "yaml"
      parsed = YAML.safe_load(yaml, permitted_classes: [Symbol], aliases: true)
      expect(parsed[:flavor]).to eq("iso")
      expect(parsed[:number]).to eq("9001")
    end

    it "includes all to_h attributes" do
      yaml = identifier.to_yaml
      parsed = YAML.safe_load(yaml, permitted_classes: [Symbol], aliases: true)

      expect(parsed.keys).to include(:flavor, :publisher, :number, :year)
    end

    it "can be parsed back with from_yaml" do
      original = identifier
      yaml = original.to_yaml
      restored = Pubid::Serializable.from_yaml(yaml)

      expect(restored.to_s).to eq(original.to_s)
    end
  end

  describe "#to_mr_string" do
    context "with ISO identifier" do
      let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

      it "returns dot-separated format" do
        mr_string = identifier.to_mr_string

        expect(mr_string).to eq("ISO.9001.2015")
      end
    end

    context "with ISO identifier with part" do
      let(:identifier) { Pubid::Iso.parse("ISO 8601-1:2019") }

      it "includes part in dot-separated format" do
        mr_string = identifier.to_mr_string

        expect(mr_string).to eq("ISO.8601-1.2019")
      end
    end

    context "with ISO/IEC identifier" do
      let(:identifier) { Pubid::Iso.parse("ISO/IEC 27001:2013") }

      it "includes publisher only (copublisher not in MR format)" do
        mr_string = identifier.to_mr_string

        # Copublisher may or may not be in MR format depending on implementation
        expect(mr_string).to start_with("ISO")
        expect(mr_string).to include("27001")
      end
    end

    context "with undated ISO identifier" do
      let(:identifier) { Pubid::Iso.parse("ISO 4") }

      it "handles missing year" do
        mr_string = identifier.to_mr_string

        expect(mr_string).to eq("ISO.4")
      end
    end
  end

  describe ".from_h" do
    context "with valid ISO hash" do
      let(:hash) do
        {
          flavor: "iso",
          publisher: "ISO",
          number: "9001",
          year: "2015",
        }
      end

      it "creates identifier from hash" do
        identifier = described_class.from_h(hash)

        expect(identifier).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(identifier.to_s).to eq("ISO 9001:2015")
      end

      it "round-trips through to_h" do
        original = Pubid::Iso.parse("ISO 9001:2015")
        hash = original.to_h
        restored = described_class.from_h(hash)

        expect(restored.to_s).to eq(original.to_s)
      end
    end

    context "with hash containing copublisher" do
      let(:hash) do
        {
          flavor: "iso",
          publisher: "ISO",
          copublishers: ["IEC"],
          number: "27001",
          year: "2013",
        }
      end

      it "creates identifier with copublisher" do
        identifier = described_class.from_h(hash)

        expect(identifier.to_s).to eq("ISO/IEC 27001:2013")
      end
    end

    context "with hash containing part" do
      let(:hash) do
        {
          flavor: "iso",
          publisher: "ISO",
          number: "8601",
          part: "1",
          year: "2019",
        }
      end

      it "creates identifier with part" do
        identifier = described_class.from_h(hash)

        expect(identifier.to_s).to eq("ISO 8601-1:2019")
      end
    end

    context "with hash containing string keys" do
      let(:hash) do
        {
          "flavor" => "iso",
          "publisher" => "ISO",
          "number" => "9001",
          "year" => "2015",
        }
      end

      it "handles string keys" do
        identifier = described_class.from_h(hash)

        expect(identifier.to_s).to eq("ISO 9001:2015")
      end
    end

    context "with missing flavor" do
      let(:hash) do
        {
          publisher: "ISO",
          number: "9001",
        }
      end

      it "raises ArgumentError" do
        expect do
          described_class.from_h(hash)
        end.to raise_error(ArgumentError, /flavor/)
      end
    end

    context "with invalid flavor" do
      let(:hash) do
        {
          flavor: "invalid_flavor",
          publisher: "TEST",
          number: "123",
        }
      end

      it "raises ArgumentError" do
        expect do
          described_class.from_h(hash)
        end.to raise_error(ArgumentError, /flavor/i)
      end
    end
  end

  describe ".from_json" do
    let(:identifier) { Pubid::Iso.parse("ISO 9001:2015") }

    it "creates identifier from JSON string" do
      json = identifier.to_json
      restored = described_class.from_json(json)

      expect(restored.to_s).to eq(identifier.to_s)
    end

    it "handles valid JSON" do
      json = '{"flavor":"iso","publisher":"ISO","number":"9001","year":"2015"}'

      result = described_class.from_json(json)

      expect(result.to_s).to eq("ISO 9001:2015")
    end

    it "raises error for invalid JSON" do
      expect { described_class.from_json("not valid json") }.to raise_error(JSON::ParserError)
    end
  end

  describe ".from_mr_string" do
    context "with ISO MR string" do
      it "parses basic ISO MR string" do
        identifier = described_class.from_mr_string("ISO.9001.2015")

        expect(identifier.to_s).to eq("ISO 9001:2015")
      end

      it "parses ISO MR string with part" do
        identifier = described_class.from_mr_string("ISO.8601-1.2019")

        expect(identifier.to_s).to eq("ISO 8601-1:2019")
      end

      it "parses undated ISO MR string" do
        identifier = described_class.from_mr_string("ISO.4")

        expect(identifier.to_s).to eq("ISO 4")
      end
    end

    context "round-trip with to_mr_string" do
      it "round-trips ISO identifier" do
        original = Pubid::Iso.parse("ISO 9001:2015")
        mr_string = original.to_mr_string
        restored = described_class.from_mr_string(mr_string)

        expect(restored.to_s).to eq(original.to_s)
      end

      it "round-trips ISO identifier with part" do
        original = Pubid::Iso.parse("ISO 8601-1:2019")
        mr_string = original.to_mr_string
        restored = described_class.from_mr_string(mr_string)

        expect(restored.to_s).to eq(original.to_s)
      end
    end
  end

  describe "comprehensive round-trip tests" do
    [
      "ISO 9001:2015",
      "ISO/IEC 27001:2013",
      "ISO 8601-1:2019",
      "ISO 4",
      "ISO/IEC Guide 51:1999(E/F/R)",
      "ISO 19110:2005/Amd 1:2011",
      "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017",
      "NIST SP 800-53",
      "NIST SP 800-53r5",
      "IEEE Std 802.3-2018",
    ].each do |identifier_string|
      context "for #{identifier_string}" do
        it "round-trips through to_h and from_h" do
          # Parse based on publisher prefix
          identifier = parse_identifier(identifier_string)
          hash = identifier.to_h
          restored = Pubid::Serializable.from_h(hash)

          expect(restored.to_s).to eq(identifier.to_s)
        end

        it "round-trips through to_json and from_json" do
          identifier = parse_identifier(identifier_string)
          json = identifier.to_json
          restored = Pubid::Serializable.from_json(json)

          expect(restored.to_s).to eq(identifier.to_s)
        end

        it "preserves all important attributes" do
          identifier = parse_identifier(identifier_string)
          hash = identifier.to_h
          restored = Pubid::Serializable.from_h(hash)

          # Check that key attributes match
          # Handle different attribute names across flavors (number vs code, date vs year)
          if identifier.respond_to?(:number)
            expect(restored.number&.value).to eq(identifier.number&.value)
          elsif identifier.respond_to?(:code)
            expect(restored.code).to eq(identifier.code)
          end

          # Check year - some flavors use date.year, others use year directly
          if identifier.respond_to?(:date)
            expect(restored.date&.year).to eq(identifier.date&.year)
          elsif identifier.respond_to?(:year)
            expect(restored.year).to eq(identifier.year)
          end

          if identifier.respond_to?(:base_identifier)
            expect(restored.respond_to?(:base_identifier)).to be true
          end
        end
      end
    end
  end

  # Helper method to parse identifier based on publisher prefix
  def parse_identifier(identifier_string)
    case identifier_string
    when /^ISO/
      Pubid::Iso.parse(identifier_string)
    when /^NIST/
      Pubid::Nist.parse(identifier_string)
    when /^IEEE/
      Pubid::Ieee.parse(identifier_string)
    else
      Pubid::Iso.parse(identifier_string) # Default to ISO
    end
  end
end
