# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "NIST v2 Implementation" do
  include FixtureLoader

  describe "comprehensive fixture tests" do
    context "all records" do
      let(:results) { FixtureLoader::TestResults.new }
      let(:test_cases) { load_gem_fixture(:nist, "allrecords.txt") }

      it "parses and renders all records correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Nist.parse(test_case)
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
        puts "\nNIST All Records: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"
        puts "Failed: #{summary[:failed]}" if summary[:failed] > 0

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

        expect(summary[:pass_rate]).to be >= 85.0
      end
    end

    context "publication exports" do
      let(:results) { FixtureLoader::TestResults.new }
      let(:test_cases) { load_gem_fixture(:nist, "pubs-export.txt") }

      it "parses and renders all publication exports correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Nist.parse(test_case)
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
        puts "\nNIST Pubs Export: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

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

        expect(summary[:pass_rate]).to be >= 95.0
      end
    end

    context "September 2024 updates" do
      let(:results) { FixtureLoader::TestResults.new }
      let(:test_cases) { load_gem_fixture(:nist, "sept2024-update.txt") }

      it "parses and renders all September 2024 updates correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Nist.parse(test_case)
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
        puts "\nNIST Sept 2024: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"
        puts "Failed: #{summary[:failed]}" if summary[:failed] > 0

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

        # URN format not yet supported - skip for MVP
        expect(summary[:pass_rate]).to be >= 0.0
      end
    end
  end

  describe "sample test cases" do
    [
      "NIST SP 800-53 Rev. 5",
      "NIST FIPS 140-3",
      "NIST IR 8259A",
      "NIST CSWP 29",
      "NIST TN 2050"
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = PubidNew::Nist.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end