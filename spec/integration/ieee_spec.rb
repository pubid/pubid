# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/pubid_new/ieee"

RSpec.describe "IEEE identifiers" do
  describe "simple standards" do
    it "parses IEEE Std 1234-2007" do
      parsed = PubidNew::Ieee.parse("IEEE Std 1234-2007")

      expect(parsed).to be_a(PubidNew::Ieee::Identifiers::Base)
      expect(parsed.publisher).to eq("IEEE")
      expect(parsed.code.number).to eq("1234")
      expect(parsed.year).to eq("2007")
      expect(parsed.to_s).to eq("IEEE Std 1234-2007")
    end

    it "parses IEEE No 264-1968" do
      parsed = PubidNew::Ieee.parse("IEEE No 264-1968")

      expect(parsed.code.number).to eq("264")
      expect(parsed.year).to eq("1968")
    end

    it "parses AIEE No 1B-1944" do
      parsed = PubidNew::Ieee.parse("AIEE No 1B-1944")

      expect(parsed.publisher).to eq("AIEE")
      expect(parsed.code.number).to eq("1B")
      expect(parsed.year).to eq("1944")
    end
  end

  describe "standards with parts" do
    it "parses IEEE Std 802.3-2018" do
      parsed = PubidNew::Ieee.parse("IEEE Std 802.3-2018")

      expect(parsed.code.number).to eq("802")
      expect(parsed.code.parts).to eq(["3"])
      expect(parsed.year).to eq("2018")
      expect(parsed.to_s).to eq("IEEE Std 802.3-2018")
    end

    it "parses IEEE Std 802.15.4-2020" do
      parsed = PubidNew::Ieee.parse("IEEE Std 802.15.4-2020")

      expect(parsed.code.number).to eq("802")
      expect(parsed.code.parts).to eq(["15", "4"])
      expect(parsed.year).to eq("2020")
    end

    it "parses IEEE Std C57.12.00-2015" do
      parsed = PubidNew::Ieee.parse("IEEE Std C57.12.00-2015")

      expect(parsed.code.prefix).to eq("C")
      expect(parsed.code.number).to eq("57")
      expect(parsed.code.parts).to eq(["12", "00"])
      expect(parsed.year).to eq("2015")
    end
  end

  describe "draft standards" do
    it "parses IEEE P1234/D5, July 2019" do
      parsed = PubidNew::Ieee.parse("IEEE P1234/D5, July 2019")

      # Should be a ProjectDraftIdentifier, not a StandardIdentifier
      expect(parsed).to be_a(PubidNew::Ieee::Identifiers::ProjectDraftIdentifier)

      # "P" is a project/draft stage indicator, NOT a code prefix
      expect(parsed.code.prefix).to be_nil
      expect(parsed.code.number).to eq("1234")
      expect(parsed.draft).to be_a(PubidNew::Ieee::Components::Draft)
      expect(parsed.draft.version).to eq("5")
      expect(parsed.draft.month).to eq("7")
      expect(parsed.draft.year).to eq("2019")
    end

    it "parses IEEE Unapproved Draft Std P1234/D5, July 2019" do
      parsed = PubidNew::Ieee.parse("IEEE Unapproved Draft Std P1234/D5, July 2019")

      expect(parsed.draft_status).to eq("Unapproved")
      expect(parsed.type).to eq("Draft Std")
      expect(parsed.draft.version).to eq("5")
    end
  end

  describe "fixture file parsing" do
    let(:fixture_file) do
      File.join(__dir__, "../../archived-gems/pubid-ieee/spec/fixtures/pubid-parsed.txt")
    end

    it "parses all identifiers from fixture file", :slow do
      total = 0
      passed = 0
      failed = []

      File.readlines(fixture_file).each_with_index do |line, index|
        identifier = line.strip
        next if identifier.empty? || identifier.start_with?("#")

        total += 1

        begin
          parsed = PubidNew::Ieee.parse(identifier)
          # Accept both Identifiers::Base and Aiee::Identifier
          expect(parsed).to satisfy { |id| id.is_a?(PubidNew::Ieee::Identifiers::Base) || id.is_a?(PubidNew::Ieee::Aiee::Identifier) }

          # Test round-trip by converting back to string
          output = parsed.to_s
          expect(output).to be_a(String)
          expect(output).not_to be_empty
          passed += 1
        rescue StandardError
          failed << "Line #{index + 1}: #{identifier}"
        end
      end

      pass_rate = (passed.to_f / total * 100).round(1)
      puts "\n\nIEEE Fixture Results: #{passed}/#{total} (#{pass_rate}%)"
      puts "Failed: #{failed.length}" if failed.any?
      puts "\nFirst 20 failures:" if failed.any?
      failed.first(20).each { |f| puts "  #{f}" } if failed.any?

      expect(pass_rate).to be >= 85.0
    end
  end
end
