# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::Exporter do
  describe "FLAVORS" do
    it "lists all 23 flavors" do
      expect(described_class::FLAVORS.size).to eq(23)
    end

    it "includes iso" do
      expect(described_class::FLAVORS).to include(:iso)
    end

    it "includes ieee" do
      expect(described_class::FLAVORS).to include(:ieee)
    end

    it "includes nist" do
      expect(described_class::FLAVORS).to include(:nist)
    end
  end

  describe "FLAVOR_STRATEGIES" do
    it "maps every flavor to a strategy" do
      described_class::FLAVORS.each do |flavor|
        expect(described_class::FLAVOR_STRATEGIES).to have_key(flavor),
          "FLAVOR_STRATEGIES missing key: #{flavor}"
      end
    end

    it "maps every strategy to a class" do
      described_class::FLAVOR_STRATEGIES.each_value do |strategy|
        expect(described_class::STRATEGY_CLASSES).to have_key(strategy),
          "STRATEGY_CLASSES missing key: #{strategy}"
      end
    end
  end

  describe ".export_all" do
    let(:data) { described_class.export_all }

    it "returns a Hash" do
      expect(data).to be_a(Hash)
    end

    it "has string top-level keys (flavor names)" do
      expect(data.keys).to all(be_a(String))
    end

    it "exports all 23 flavors" do
      expect(data.size).to eq(23)
    end

    it "exports ISO with identifier types" do
      expect(data["iso"]).to be_a(Hash)
      expect(data["iso"][:identifier_types]).to be_a(Array)
      expect(data["iso"][:identifier_types].size).to be > 0
    end

    it "exports IEC with identifier types" do
      expect(data["iec"][:identifier_types].size).to be >= 12
    end

    it "exports IEEE with identifier types" do
      expect(data["ieee"][:identifier_types].size).to be > 0
    end

    it "exports NIST with identifier types" do
      expect(data["nist"][:identifier_types].size).to be > 0
    end

    it "exports BSI with identifier types" do
      expect(data["bsi"][:identifier_types].size).to be >= 23
    end

    it "exports ETSI with identifier types" do
      expect(data["etsi"][:identifier_types].size).to be > 0
    end

    it "produces 162+ total identifier types" do
      total = data.values.sum { |f| f[:identifier_types]&.size || 0 }
      expect(total).to be >= 162
    end
  end

  describe "export data structure" do
    let(:data) { described_class.export_all }
    let(:iso_types) { data["iso"][:identifier_types] }
    let(:is_type) { iso_types.find { |t| t[:key] == "is" } }

    it "each identifier type has required fields" do
      iso_types.each do |type|
        expect(type).to have_key(:key)
        expect(type).to have_key(:title)
        expect(type).to have_key(:short)
        expect(type).to have_key(:abbr)
        expect(type).to have_key(:typed_stages)
        expect(type).to have_key(:examples)
      end
    end

    it "has the International Standard type" do
      expect(is_type).not_to be_nil
      expect(is_type[:title]).to eq("International Standard")
    end

    it "includes typed stages for International Standard" do
      expect(is_type[:typed_stages].size).to be > 0
    end

    it "each typed stage has required fields" do
      is_type[:typed_stages].each do |ts|
        expect(ts).to have_key(:stage_code)
        expect(ts).to have_key(:type_code)
        expect(ts).to have_key(:abbr)
        expect(ts).to have_key(:name)
        expect(ts).to have_key(:harmonized_stages)
      end
    end

    it "includes DIS typed stage for International Standard" do
      dis = is_type[:typed_stages].find { |ts| ts[:stage_code] == "dis" }
      expect(dis).not_to be_nil
      expect(dis[:abbr]).to include("DIS")
      expect(dis[:harmonized_stages]).to include("40.00")
    end

    it "includes examples for ISO" do
      types_with_examples = iso_types.select { |t| t[:examples]&.any? }
      expect(types_with_examples.size).to be > 0
    end

    it "limits examples to 10 per type" do
      iso_types.each do |type|
        expect(type[:examples].size).to be <= 10
      end
    end
  end

  describe "strategy dispatch" do
    it "uses SchemeExporter for ISO" do
      expect(described_class::FLAVOR_STRATEGIES[:iso]).to eq(:scheme)
    end

    it "uses IeeeExporter for IEEE" do
      expect(described_class::FLAVOR_STRATEGIES[:ieee]).to eq(:ieee)
    end

    it "uses NistExporter for NIST" do
      expect(described_class::FLAVOR_STRATEGIES[:nist]).to eq(:nist)
    end

    it "uses RegistryExporter for BSI" do
      expect(described_class::FLAVOR_STRATEGIES[:bsi]).to eq(:registry)
    end

    it "uses RegistryExporter for CEN-CENELEC" do
      expect(described_class::FLAVOR_STRATEGIES[:cen_cenelec]).to eq(:registry)
    end

    it "uses DataClassExporter for ETSI" do
      expect(described_class::FLAVOR_STRATEGIES[:etsi]).to eq(:data_class)
    end

    it "uses DataClassExporter for Plateau" do
      expect(described_class::FLAVOR_STRATEGIES[:plateau]).to eq(:data_class)
    end

    it "uses ItuExporter for ITU" do
      expect(described_class::FLAVOR_STRATEGIES[:itu]).to eq(:itu)
    end
  end
end
