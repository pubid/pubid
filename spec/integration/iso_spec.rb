# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "ISO v2 Implementation" do
  include FixtureLoader

  let(:results) { FixtureLoader::TestResults.new }

  describe "comprehensive fixture tests" do
    context "ISO identifiers" do
      let(:test_cases) { load_gem_fixture(:iso, "iso-pubid-basic.txt") }

      it "parses and renders all ISO identifiers correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Iso.parse(test_case)
            rendered = identifier.to_s

            if test_case == rendered
              results.record_pass
            else
              results.record_fail(test_case, test_case, rendered)
            end
          rescue => e
            results.record_error(test_case, e)
          end
        end

        summary = results.summary
        puts "\nISO Identifiers: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 20 failures for analysis
        if results.errors.any?
          puts "\nFirst 20 failures:"
          results.errors.first(20).each do |error|
            if error[:type] == :mismatch
              puts "  ~ #{error[:test]}"
              puts "    => #{error[:actual]}"
            else
              puts "  ✗ #{error[:test]}"
              puts "    => #{error[:error]}"
            end
          end
        end

        expect(summary[:pass_rate]).to be >= 90.0
      end
    end
  end

  describe "sample test cases" do
    [
      "ISO 9001:2015",
      "ISO/IEC 17025:2017",
      "ISO 14001:2015"
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = PubidNew::Iso.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end