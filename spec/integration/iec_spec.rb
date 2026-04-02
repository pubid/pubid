# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "IEC v2 Implementation" do
  include FixtureLoader

  describe "comprehensive fixture tests" do
    before(:all) do
      @overall_results = FixtureLoader::TestResults.new
    end

    context "CSV identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "csv-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all CSV identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC CSV: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "IEC identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "iec-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all IEC identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC Standard: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "IECEE TRF identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "iecee-trf-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all IECEE TRF identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC IECEE TRF: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "IECEx TRF identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "iecex-trf-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all IECEx TRF identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC IECEx TRF: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "IECQ identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "iecq-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all IECQ identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC IECQ: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "ISH identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "ish-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all ISH identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC ISH: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "ISO/IEC identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "iso-iec-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all ISO/IEC identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC ISO/IEC: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "Sheets identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "sheets-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all Sheets identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC Sheets: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "TC1 identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "tc1-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all TC1 identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC TC1: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "TR identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "tr-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all TR identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC TR: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "TS identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "ts-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all TS identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC TS: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "VAP identifiers" do
      let(:test_cases) { load_gem_fixture(:iec, "vap-pubid.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all VAP identifiers correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC VAP: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "WD special groups" do
      let(:test_cases) { load_gem_fixture(:iec, "wd-special-groups.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all WD special groups correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC WD Special Groups: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "Working documents" do
      let(:test_cases) { load_gem_fixture(:iec, "working-documents.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all working documents correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC Working Documents: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    context "Working programmes" do
      let(:test_cases) { load_gem_fixture(:iec, "working-programmes.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all working programmes correctly" do
        test_cases.each do |test_case|
          identifier = Pubid::Iec.parse(test_case)
          rendered = identifier.to_s

          if test_case == rendered
            results.record_pass
            @overall_results.record_pass
          else
            results.record_fail(test_case, test_case, rendered)
            @overall_results.record_fail(test_case, test_case, rendered)
          end
        rescue StandardError => e
          results.record_error(test_case, e)
          @overall_results.record_error(test_case, e)
        end

        summary = results.summary
        puts "\nIEC Working Programmes: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

        # Show first 10 failures for this category
        if results.errors.any?
          puts "  First 10 failures:"
          results.errors.first(10).each do |error|
            if error[:type] == :mismatch
              puts "    ~ #{error[:test]}"
              puts "      => #{error[:actual]}"
            else
              puts "    ✗ #{error[:test]}"
              puts "      => #{error[:error]}"
            end
          end
        end
      end
    end

    after(:all) do
      summary = @overall_results.summary
      puts "\n" + "=" * 80
      puts "OVERALL IEC RESULTS: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"
      puts "=" * 80

      # Show first 20 failures overall
      if @overall_results.errors.any?
        puts "\nFirst 20 failures overall:"
        @overall_results.errors.first(20).each do |error|
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

  describe "sample test cases" do
    [
      "IEC 60027-1:1992",
      "IEC 60050-113:2011",
      "IEC TR 62048:2011",
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = Pubid::Iec.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end
