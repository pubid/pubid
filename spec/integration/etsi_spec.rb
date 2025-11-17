# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "ETSI v2 Implementation" do
  include FixtureLoader

  describe "comprehensive fixture tests" do
    before(:all) do
      @overall_results = FixtureLoader::TestResults.new
    end

    context "ETSI identifiers" do
      let(:test_cases) { load_gem_fixture(:etsi, "pubids.txt") }
      let(:results) { FixtureLoader::TestResults.new }

      it "parses and renders all ETSI identifiers correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Etsi.parse(test_case)
            rendered = identifier.to_s

            if test_case == rendered
              results.record_pass
              @overall_results.record_pass
            else
              results.record_fail(test_case, test_case, rendered)
              @overall_results.record_fail(test_case, test_case, rendered)
            end
          rescue => e
            results.record_error(test_case, e)
            @overall_results.record_error(test_case, e)
          end
        end

        summary = results.summary
        puts "\nETSI: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"
      end
    end

    after(:all) do
      summary = @overall_results.summary
      puts "\n" + "=" * 80
      puts "OVERALL ETSI RESULTS: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"
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
      "ETSI GS ZSM 012 V1.1.1 (2022-12)",
      "ETSI GS ZSM 009-2 V1.1.1 (2022-06)",
      "ETSI GR SAI 013 V1.1.1 (2023-03)"
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = PubidNew::Etsi.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end