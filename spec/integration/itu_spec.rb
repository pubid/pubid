# frozen_string_literal: true

require "spec_helper"
require_relative "../support/fixture_loader"

RSpec.describe "ITU v2 Implementation" do
  include FixtureLoader

  let(:results) { FixtureLoader::TestResults.new }

  describe "comprehensive fixture tests" do
    context "ITU-R recommendations" do
      let(:test_cases) { load_gem_fixture(:itu, "itu-r.txt") }

      it "parses and renders all ITU-R recommendations correctly" do
        test_cases.each do |test_case|
          begin
            identifier = PubidNew::Itu.parse(test_case)
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
        puts "\nITU-R: #{summary[:passed]}/#{summary[:total]} (#{summary[:pass_rate]}%)"

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
  end

  describe "sample test cases" do
    [
      "ITU-R BT.709-6",
      "ITU-R BS.1770-4",
      "ITU-R M.585-7"
    ].each do |test_case|
      it "correctly parses and renders '#{test_case}'" do
        identifier = PubidNew::Itu.parse(test_case)
        expect(identifier.to_s).to eq(test_case)
      end
    end
  end
end