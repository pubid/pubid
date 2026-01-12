# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/itu"

RSpec.describe "ITU Integration" do
  describe "parsing and rendering" do
    shared_examples "parses and renders correctly" do |input, expected_output = nil|
      it "parses and renders #{input}" do
        expected = expected_output || input
        identifier = PubidNew::Itu.parse(input)
        expect(identifier.to_s).to eq(expected)
      end
    end

    context "ITU-R recommendations" do
      include_examples "parses and renders correctly", "ITU-R BO.600-1"
      include_examples "parses and renders correctly", "ITU-R BO.791-0"
      include_examples "parses and renders correctly", "ITU-R V.1234-1"
    end

    context "with subseries" do
      include_examples "parses and renders correctly", "ITU-R BO.1234.5-2"
    end
  end

  describe "parsing all fixtures" do
    it "parses all ITU-R identifiers" do
      fixture_file = File.join(__dir__,
                               "../fixtures/itu/identifiers/full/recommendation.txt")

      File.readlines(fixture_file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        expect do
          identifier = PubidNew::Itu.parse(line)
          expect(identifier.to_s).to eq(line)
        end.not_to raise_error, "Failed to parse: #{line}"
      end
    end
  end
end
