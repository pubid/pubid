# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "CCSDS v2 Implementation" do
  include FixtureLoader

  let(:results) { FixtureLoader::TestResults.new }

  describe "comprehensive fixture tests" do
    context "active publications" do
      let(:test_cases) { load_gem_fixture(:ccsds, "active-publications.txt") }

      it "parses and renders all active publications correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Ccsds.parse(test_case)
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
        puts "\nCCSDS Active Publications: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures
        if results.errors.any?
          puts "\nFirst 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "  ~ #{error[:test]}"
              puts "    => #{error[:actual]}"
            else
              puts "  ✗ #{error[:test]}"
              puts "    => #{error[:error]}"
            end
          end
        end

        expect(summary[:pass_rate]).to be >= 95.0
      end
    end

    context "historical publications" do
      let(:test_cases) { load_gem_fixture(:ccsds, "historical-publications.txt") }

      it "parses and renders all historical publications correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Ccsds.parse(test_case)
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
        puts "\nCCSDS Historical Publications: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures
        if results.errors.any?
          puts "\nFirst 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "  ~ #{error[:test]}"
              puts "    => #{error[:actual]}"
            else
              puts "  ✗ #{error[:test]}"
              puts "    => #{error[:error]}"
            end
          end
        end

        expect(summary[:pass_rate]).to be >= 95.0
      end
    end
  end

  describe "sample test cases" do
    [
      "CCSDS 123.1-B-1",
      "CCSDS A123.1-G-2",
      "CCSDS 123.1-B-1-S",
      "CCSDS 123.1-B-1 Cor. 1"
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = PubidNew::Ccsds.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end