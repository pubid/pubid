# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/etsi"

RSpec.describe "ETSI Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      hash = id.to_h

      expect(hash[:flavor]).to eq("etsi")
      expect(hash[:publisher]).to eq("ETSI")
      expect(hash[:type]).to eq("EN")
      expect(hash[:number]).to eq("300 100")
      expect(hash[:year]).to eq("1998")
      expect(hash[:month]).to eq("04")
      expect(hash[:version]).to eq("V1.1.1")
    end

    it "exports identifier with part" do
      id = Pubid::Etsi.parse("ETSI EN 300 100-1 V1.1.1 (1998-04)")
      hash = id.to_h

      expect(hash[:number]).to eq("300 100-1")
    end

    it "exports amendment with supplement notation" do
      id = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      hash = id.to_h

      expect(hash[:supplement_notation]).to eq("A1")
      expect(hash[:supplement_type]).to eq("amendment")
    end

    it "exports corrigendum with supplement notation" do
      id = Pubid::Etsi.parse("ETSI TR 101 100/C1 V1.1.1 (1997-07)")
      hash = id.to_h

      expect(hash[:supplement_notation]).to eq("C1")
      expect(hash[:supplement_type]).to eq("corrigendum")
    end
  end

  describe "#to_json" do
    it "exports basic identifier as JSON" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("etsi")
      expect(parsed["type"]).to eq("EN")
      expect(parsed["number"]).to eq("300 100")
    end

    it "exports amendment as JSON" do
      id = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["supplement_notation"]).to eq("A1")
      expect(parsed["supplement_type"]).to eq("amendment")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ETSI.300 100.1998")
    end

    it "exports identifier with part as MR string" do
      id = Pubid::Etsi.parse("ETSI EN 300 100-1 V1.1.1 (1998-04)")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ETSI.300 100-1.1998")
    end

    it "exports amendment as MR string" do
      id = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ETSI.300 011.1994")
    end
  end

  describe ".from_h" do
    it "creates basic identifier from hash" do
      hash = {
        flavor: "etsi",
        publisher: "ETSI",
        type: "EN",
        number: "300 100",
        year: "1998",
        month: "04",
        version: "V1.1.1"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("ETSI EN 300 100 V1.1.1 (1998-04)")
    end

    it "creates identifier with part from hash" do
      hash = {
        flavor: "etsi",
        publisher: "ETSI",
        type: "EN",
        number: "300 100-1",
        year: "1998",
        month: "04",
        version: "V1.1.1"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("ETSI EN 300 100-1 V1.1.1 (1998-04)")
    end

    it "creates amendment from hash" do
      hash = {
        flavor: "etsi",
        publisher: "ETSI",
        type: "ETS",
        number: "300 011",
        year: "1994",
        month: "12",
        version: "ed.1",
        supplement_notation: "A1",
        supplement_type: "amendment"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("ETSI ETS 300 011/A1 ed.1 (1994-12)")
    end

    it "creates corrigendum from hash" do
      hash = {
        flavor: "etsi",
        publisher: "ETSI",
        type: "TR",
        number: "101 100",
        year: "1997",
        month: "07",
        version: "V1.1.1",
        supplement_notation: "C1",
        supplement_type: "corrigendum"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("ETSI TR 101 100/C1 V1.1.1 (1997-07)")
    end
  end

  describe ".from_json" do
    it "creates basic identifier from JSON" do
      json = '{"flavor":"etsi","publisher":"ETSI","type":"EN","number":"300 100","year":"1998","month":"04","version":"V1.1.1"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("ETSI EN 300 100 V1.1.1 (1998-04)")
    end

    it "creates amendment from JSON" do
      json = '{"flavor":"etsi","publisher":"ETSI","type":"ETS","number":"300 011","year":"1994","month":"12","version":"ed.1","supplement_notation":"A1","supplement_type":"amendment"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("ETSI ETS 300 011/A1 ed.1 (1994-12)")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion for basic identifier" do
      original = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through hash conversion for amendment" do
      original = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through hash conversion for corrigendum" do
      original = Pubid::Etsi.parse("ETSI TR 101 100/C1 V1.1.1 (1997-07)")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Etsi.parse("ETSI EG 200 053 V1.5.1 (2004-06)")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
