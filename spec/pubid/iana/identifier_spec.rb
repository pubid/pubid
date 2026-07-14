# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iana::Identifier do
  describe ".parse" do
    context "with a top registry (IANA-prefixed)" do
      subject { "IANA _6lowpan-parameters" }

      let(:parsed) { described_class.parse(subject) }

      it "parses as Registry" do
        expect(parsed).to be_a(Pubid::Iana::Identifiers::Registry)
      end

      it "parses the registry slug" do
        expect(parsed.registry).to eq("_6lowpan-parameters")
      end

      it "has no sub_registry" do
        expect(parsed.sub_registry).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders the bare slug without the publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("_6lowpan-parameters")
      end
    end

    context "with a sub-registry (IANA-prefixed)" do
      subject { "IANA _6lowpan-parameters/lowpan_nhc" }

      let(:parsed) { described_class.parse(subject) }

      it "parses the registry slug" do
        expect(parsed.registry).to eq("_6lowpan-parameters")
      end

      it "parses the sub_registry slug" do
        expect(parsed.sub_registry).to eq("lowpan_nhc")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders the bare slug without the publisher" do
        expect(parsed.to_s(with_publisher: false))
          .to eq("_6lowpan-parameters/lowpan_nhc")
      end
    end

    context "with a bare index-key slug (no IANA prefix)" do
      it "normalizes a top registry to the IANA-prefixed printed form" do
        expect(described_class.parse("calipso").to_s).to eq("IANA calipso")
      end

      it "normalizes a sub-registry to the IANA-prefixed printed form" do
        parsed = described_class.parse("sip-parameters/sip-parameters-13")
        expect(parsed.to_s).to eq("IANA sip-parameters/sip-parameters-13")
        expect(parsed.registry).to eq("sip-parameters")
        expect(parsed.sub_registry).to eq("sip-parameters-13")
      end
    end

    context "with dotted slugs" do
      subject { "IANA idna-tables-11.0.0/idna-tables-context" }

      let(:parsed) { described_class.parse(subject) }

      it "keeps dots verbatim in registry and sub_registry" do
        expect(parsed.registry).to eq("idna-tables-11.0.0")
        expect(parsed.sub_registry).to eq("idna-tables-context")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    it "rejects input longer than MAX_INPUT_LENGTH" do
      expect { described_class.parse("IANA #{'a' * Pubid::MAX_INPUT_LENGTH}") }
        .to raise_error(ArgumentError)
    end
  end
end
