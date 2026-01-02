# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/iso"

RSpec.describe "ISO Integration" do
  describe "basic parsing" do
    shared_examples "parses correctly" do |input, expected = nil|
      it "parses #{input}" do
        expect { PubidNew::Iso.parse(input) }.not_to raise_error
        id = PubidNew::Iso.parse(input)
        expect(id.to_s).to eq(expected || input) if expected
      end
    end

    include_examples "parses correctly", "ISO 123"
    include_examples "parses correctly", "ISO 123:2020"
    include_examples "parses correctly", "ISO 123-1:2020"
    include_examples "parses correctly", "ISO/IEC 13818-1:2015"
    include_examples "parses correctly", "ISO Guide 71:2014"
    include_examples "parses correctly", "ISO GUIDE 1:1972"
    include_examples "parses correctly", "ISO/TR 1234:2020"
    include_examples "parses correctly", "ISO/TS 1234:2020"
  end

  describe "parsing all basic fixtures" do
    it "parses all basic ISO identifiers" do
      fixture = File.join(__dir__, "../fixtures/iso/identifiers/full/iso-pubid-basic.txt")
      lines = File.readlines(fixture).map(&:strip).reject { |l| l.empty? || l.start_with?("#") }

      failed = []
      lines.each do |line|
        begin
          PubidNew::Iso.parse(line)
        rescue => e
          failed << line
        end
      end

      puts "\n\nFailed to parse #{failed.size}/#{lines.size} identifiers" if failed.any?
      failed.first(10).each { |f| puts "  - #{f}" } if failed.any?

      expect(failed.size).to eq(0), "Failed to parse #{failed.size} identifiers"
    end
  end
end