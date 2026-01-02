# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/ccsds"

RSpec.describe "CCSDS Integration" do
  describe "parsing and rendering" do
    shared_examples "parses and renders correctly" do |input, expected_output = nil|
      it "parses and renders #{input}" do
        expected = expected_output || input
        identifier = PubidNew::Ccsds.parse(input)
        expect(identifier.to_s).to eq(expected)
      end
    end

    context "basic formats" do
      include_examples "parses and renders correctly", "CCSDS 120.0-G-4"
      include_examples "parses and renders correctly", "CCSDS 121.0-B-3"
      include_examples "parses and renders correctly", "CCSDS 130.0-G-4"
    end

    context "with corrigenda" do
      include_examples "parses and renders correctly", "CCSDS 123.0-B-2 Cor. 1"
      include_examples "parses and renders correctly", "CCSDS 123.0-B-2 Cor. 2"
    end
  end

  describe "parsing all fixtures" do
    it "parses all CCSDS identifiers from fixtures" do
      fixture_file = File.join(__dir__, "../fixtures/ccsds/identifiers/full/international_standard.txt")

      File.readlines(fixture_file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        # Strip metadata notes (anything after " - ")
        clean_line = line.split(" - ").first

        expect {
          identifier = PubidNew::Ccsds.parse(clean_line)
          expect(identifier.to_s).to eq(clean_line)
        }.not_to raise_error, "Failed to parse: #{clean_line}"
      end
    end
  end
end