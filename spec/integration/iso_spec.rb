# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid/iso"

RSpec.describe "ISO Integration" do
  describe "basic parsing" do
    shared_examples "parses correctly" do |input, expected = nil|
      it "parses #{input}" do
        expect { Pubid::Iso.parse(input) }.not_to raise_error
        id = Pubid::Iso.parse(input)
        expect(id.to_s).to eq(expected || input) if expected
      end
    end

    it_behaves_like "parses correctly", "ISO 123"
    it_behaves_like "parses correctly", "ISO 123:2020"
    it_behaves_like "parses correctly", "ISO 123-1:2020"
    it_behaves_like "parses correctly", "ISO/IEC 13818-1:2015"
    it_behaves_like "parses correctly", "ISO Guide 71:2014"
    it_behaves_like "parses correctly", "ISO GUIDE 1:1972"
    it_behaves_like "parses correctly", "ISO/TR 1234:2020"
    it_behaves_like "parses correctly", "ISO/TS 1234:2020"
  end

  describe "parsing all basic fixtures" do
    it "parses all basic ISO identifiers" do
      fixture = File.join(__dir__,
                          "../fixtures/iso/identifiers/full/iso-pubid-basic.txt")
      lines = File.readlines(fixture).map(&:strip).reject do |l|
        l.empty? || l.start_with?("#")
      end

      failed = []
      lines.each do |line|
        Pubid::Iso.parse(line)
      rescue StandardError
        failed << line
      end

       if failed.any?
      failed.first(10).each { |f|  } if failed.any?

      expect(failed.size).to eq(0), "Failed to parse #{failed.size} identifiers"
    end
  end
end
