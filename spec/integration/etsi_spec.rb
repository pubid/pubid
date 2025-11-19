# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/etsi"

RSpec.describe "ETSI Integration" do
  describe "parsing and rendering" do
    shared_examples "parses and renders correctly" do |input, expected_output = nil|
      it "parses and renders #{input}" do
        expected = expected_output || input
        identifier = PubidNew::Etsi.parse(input)
        expect(identifier.to_s).to eq(expected)
      end
    end

    context "basic standards" do
      include_examples "parses and renders correctly", "ETSI GS ZSM 012 V1.1.1 (2022-12)"
      include_examples "parses and renders correctly", "ETSI GR ZSM 011 V1.1.1 (2023-02)"
      include_examples "parses and renders correctly", "ETSI GS QKD 018 V1.1.1 (2022-04)"
    end

    context "with parts" do
      include_examples "parses and renders correctly", "ETSI GR ZSM 009-3 V1.1.1 (2023-08)"
      include_examples "parses and renders correctly", "ETSI GS ZSM 009-2 V1.1.1 (2022-06)"
    end

    context "all type variants" do
      include_examples "parses and renders correctly", "ETSI EN 301 234 V1.0.0 (2020-01)"
      include_examples "parses and renders correctly", "ETSI ES 201 567 V2.1.1 (2019-05)"
      include_examples "parses and renders correctly", "ETSI EG 202 789 V1.2.0 (2021-03)"
      include_examples "parses and renders correctly", "ETSI TS 102 456 V3.0.1 (2022-06)"
      include_examples "parses and renders correctly", "ETSI ETR 299 V1.0.0 (1996-09)"
      include_examples "parses and renders correctly", "ETSI ETS 300 123 V1.0.0 (1995-03)"
      include_examples "parses and renders correctly", "ETSI TBR 038 V2.0.0 (1998-12)"
      include_examples "parses and renders correctly", "ETSI NET 123 V1.0.0 (1997-06)"
      include_examples "parses and renders correctly", "ETSI GR ABC 001 V1.1.1 (2023-01)"
      include_examples "parses and renders correctly", "ETSI GS XYZ 123 V2.0.0 (2022-12)"
      include_examples "parses and renders correctly", "ETSI SR 001 234 V1.0.0 (2020-05)"
      include_examples "parses and renders correctly", "ETSI TR 103 567 V1.2.1 (2021-08)"
    end

    context "GSM format" do
      include_examples "parses and renders correctly", "ETSI GTS GSM 02.01 V5.5.0 (1999-01)"
    end
  end

  describe "parsing all fixtures" do
    it "parses all identifiers from pubids.txt" do
      fixture_file = File.join(__dir__, "../../gems/pubid-etsi/spec/fixtures/pubids.txt")

      File.readlines(fixture_file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        expect {
          identifier = PubidNew::Etsi.parse(line)
          expect(identifier.to_s).to eq(line)
        }.not_to raise_error, "Failed to parse: #{line}"
      end
    end
  end
end