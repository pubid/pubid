# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iec"

RSpec.describe "IEC URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011")
    end

    it "generates URN with part" do
      id = Pubid::Iec.parse("IEC 60050-100:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:-100:2011")
    end

    # IEC compound part designators (e.g. IEC 61010-2-201) are stored
    # internally as part="2"/subpart="201" but must serialize to the URN
    # as a single colon-segment ":-2-201", not two separate segments
    # ":-2:-201". This locks the round-trip so parse_urn reads the same
    # compound part back.
    it "generates URN with compound part as a single segment" do
      id = Pubid::Iec.parse("IEC 61010-2-201:2017")
      expect(id.to_urn).to eq("urn:iec:std:iec:61010:-2-201:2017")
    end

    it "round-trips compound-part URN through parse_urn" do
      id = Pubid::Iec.parse_urn("urn:iec:std:iec:61010:-2-201:2017")
      expect(id.to_urn).to eq("urn:iec:std:iec:61010:-2-201:2017")
      expect(id.to_s).to eq("IEC 61010-2-201:2017")
    end

    # Wrapper identifiers (VAP, Fragment, Sheet) had no `to_urn` on their
    # base class, and the URN parser did not consume `vap.X` / `frag.X` /
    # `sheet.X` tokens — so the wrapper info was dropped on URN round-trip.
    # `lib/pubid/iec/identifier.rb` now defines `to_urn` on the IEC base
    # `Identifier`, and `lib/pubid/iec/urn_parser.rb` extracts the wrapper
    # tokens before the supplements loop and reapplies them after build.
    describe "wrapper identifier URN round-trip" do
      it "round-trips a VapIdentifier (RLV)" do
        id = Pubid::Iec.parse("IEC 61010-2-201:2017 RLV")
        expect(id.to_urn).to eq("urn:iec:std:iec:61010:-2-201:2017:vap.rlv")
        rt = Pubid::Iec.parse_urn(id.to_urn)
        expect(rt).to be_a(Pubid::Iec::Identifiers::VapIdentifier)
        expect(rt.to_s).to eq("IEC 61010-2-201:2017 RLV")
        expect(rt.to_urn).to eq(id.to_urn)
      end

      it "round-trips a FragmentIdentifier" do
        id = Pubid::Iec.parse("IEC 60050-191/AMD2/FRAG2")
        rt = Pubid::Iec.parse_urn(id.to_urn)
        expect(rt).to be_a(Pubid::Iec::Identifiers::FragmentIdentifier)
        expect(rt.to_s).to eq("IEC 60050-191/AMD2/FRAG2")
        expect(rt.to_urn).to eq(id.to_urn)
      end
    end

    it "generates URN with amendment" do
      id = Pubid::Iec.parse("IEC 60050:2011/Amd 1:2015")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011:amd:2015:v1")
    end

    it "generates URN for undated identifier" do
      id = Pubid::Iec.parse("IEC 60050")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to start_with("urn:iec:")
    end
  end
end
