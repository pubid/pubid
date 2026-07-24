# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Omg::Identifier do
  describe ".parse" do
    context "acronym + version" do
      subject(:parsed) { described_class.parse("OMG AMI4CCM 1.0") }

      it "captures acronym" do
        expect(parsed.acronym).to eq("AMI4CCM")
      end

      it "captures version" do
        expect(parsed.version).to eq("1.0")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("OMG AMI4CCM 1.0")
      end
    end

    context "mixed-case acronym (SysML)" do
      it "round-trips" do
        expect(described_class.parse("OMG SysML 1.6").to_s).to eq("OMG SysML 1.6")
      end
    end

    context "version with beta suffix" do
      it "captures the full version string" do
        expect(described_class.parse("OMG DDS 5 beta 3").version).to eq("5 beta 3")
      end
    end

    context "acronym only" do
      it "round-trips" do
        expect(described_class.parse("OMG CORBA").to_s).to eq("OMG CORBA")
      end
    end

    it "raises on malformed input" do
      expect { described_class.parse("OMG") }.to raise_error(/Failed to parse/)
    end
  end
end
