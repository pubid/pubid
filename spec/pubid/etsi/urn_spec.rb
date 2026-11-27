# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/etsi"

RSpec.describe "ETSI URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      urn = id.to_urn
      expect(urn).to start_with("urn:etsi:")
    end

    it "generates URN for amendment" do
      id = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      urn = id.to_urn
      expect(urn).to start_with("urn:etsi:")
    end

    # The two differential rows: every corpus month 08/09 row crashed
    # urn_date with `ArgumentError: invalid value for Integer()` — the
    # zero-padded string went through %d, which reads "08"/"09" as
    # octal look-alikes and refuses them.
    it "generates URN for a month-09 date" do
      id = Pubid::Etsi.parse("ETSI EN 302 636-5-1 V1.2.1 (2014-08)")
      expect(id.to_urn).to eq("urn:etsi:en:302 636-5-1:v1.2.1:2014-08")
    end

    it "generates URN for a month-08 date" do
      id = Pubid::Etsi.parse("ETSI TS 123 207 V6.6.0 (2005-09)")
      expect(id.to_urn).to eq("urn:etsi:ts:123 207:v6.6.0:2005-09")
    end

    it "generates URN for an edition-carrying month-09 date" do
      id = Pubid::Etsi.parse("ETSI TBR 013 ed.3 (1999-09)")
      expect(id.to_urn).to eq("urn:etsi:tbr:013:ed.3:1999-09")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = Pubid::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      expect(id.to_urn).to start_with("urn:etsi:")
    end
  end
end
