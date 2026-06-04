# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Iec all parts / series URN" do
  describe "parsing (all parts) notation" do
    subject { Pubid::Iec::Identifier.parse("IEC 80000 (all parts)") }

    it "sets all_parts to a boolean true" do
      expect(subject.all_parts).to be true
    end

    it "renders the (all parts) suffix" do
      expect(subject.to_s).to eq("IEC 80000 (all parts)")
    end

    it "generates a series URN with the ser deliverable slot" do
      expect(subject.to_urn).to eq("urn:iec:std:iec:80000:::ser")
    end

    it "defaults all_parts to false when not specified" do
      id = Pubid::Iec::Identifier.parse("IEC 80000")
      expect(id.all_parts).to be false
    end
  end

  describe "parsing a series URN" do
    subject { Pubid::Iec::Identifier.parse("urn:iec:std:iec:80000:::ser") }

    it "sets all_parts to true" do
      expect(subject.all_parts).to be true
    end

    it "renders the (all parts) suffix" do
      expect(subject.to_s).to eq("IEC 80000 (all parts)")
    end

    it "round-trips back to the same URN" do
      expect(subject.to_urn).to eq("urn:iec:std:iec:80000:::ser")
    end
  end

  describe "routing of non-series URNs (guards the new URN dispatch)" do
    it "parses a plain dated URN via Identifier.parse" do
      id = Pubid::Iec::Identifier.parse("urn:iec:std:iec:60050:2011")
      expect(id.to_s).to eq("IEC 60050:2011")
      expect(id.all_parts).to be false
    end
  end
end
