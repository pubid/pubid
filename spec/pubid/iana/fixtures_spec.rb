# frozen_string_literal: true

require "spec_helper"

module IanaFixturesSpec
  PASS_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/iana/identifiers/pass", "*.txt"),
  ).freeze
  FAIL_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/iana/identifiers/fail", "*.txt"),
  ).freeze
end

RSpec.describe "IANA Fixture Round-trip" do
  include FixtureFileHelper

  IanaFixturesSpec::PASS_FILES.each do |fixture_file|
    describe "pass/#{File.basename(fixture_file)}" do
      let(:identifiers) { read_fixture_file(fixture_file) }

      it "parses and round-trips every identifier verbatim" do
        results = test_round_trip(identifiers, Pubid::Iana)

        expect(results[:failures])
          .to be_empty, -> { results[:failures].first(10).inspect }
        expect(results[:pass_rate]).to eq(100.0)
      end
    end
  end

  IanaFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "fail/#{File.basename(fixture_file)}" do
      let(:malformed) { read_fixture_file(fixture_file) }

      it "rejects every malformed identifier" do
        expect(malformed).not_to be_empty

        accepted = malformed.select do |pubid|
          Pubid::Iana.parse(pubid)
          true
        rescue StandardError
          false
        end

        expect(accepted)
          .to be_empty, "unexpectedly parsed malformed ids: #{accepted.inspect}"
      end
    end
  end
end
