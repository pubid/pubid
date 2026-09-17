# frozen_string_literal: true

require "spec_helper"

module GbFixturesSpec
  # spec/pubid/gb/ is two levels below spec/fixtures/, and the flavor
  # directory is lowercase. A wrong glob reports 0 examples instead of a
  # failure, so the tripwire example below asserts both globs are non-empty.
  PASS_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/gb/pass", "*.txt"),
  ).freeze
  FAIL_FILES = Dir.glob(
    File.join(__dir__, "../../fixtures/gb/fail", "*.txt"),
  ).freeze
end

RSpec.describe "GB fixtures" do
  include FixtureFileHelper

  it "finds the fixture files" do
    expect(GbFixturesSpec::PASS_FILES).not_to be_empty
    expect(GbFixturesSpec::FAIL_FILES).not_to be_empty
  end

  describe "pass fixtures" do
    GbFixturesSpec::PASS_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        let(:entries) { read_pass_fixture_entries(fixture_file) }

        it "renders every identifier as recorded" do
          failures = entries.filter_map do |input, expected|
            rendered = Pubid::Gb.parse(input).to_s
            next if rendered == expected

            { original: input, rendered: rendered, expected: expected }
          rescue StandardError => e
            { original: input, error: "#{e.class}: #{e.message}" }
          end

          expect(failures).to be_empty,
                              "round-trip failures: #{failures.inspect}"
        end

        it "routes every identifier through the global dispatcher" do
          failures = entries.filter_map do |input, _expected|
            resolved = Pubid.parse(input)
            next if resolved.is_a?(Pubid::Gb::Identifier)

            { original: input, resolved: resolved.class.to_s }
          rescue StandardError => e
            { original: input, error: "#{e.class}: #{e.message}" }
          end

          expect(failures).to be_empty,
                              "dispatcher routing failures: #{failures.inspect}"
        end

        it "keeps every identifier equal across a hash round trip" do
          failures = entries.filter_map do |input, _expected|
            identifier = Pubid::Gb.parse(input)
            back = Pubid::Gb::Identifier.from_hash(identifier.to_hash)
            next if back == identifier

            { original: input, hash: identifier.to_hash, back: back.to_s }
          rescue StandardError => e
            { original: input, error: "#{e.class}: #{e.message}" }
          end

          expect(failures).to be_empty,
                              "hash round-trip failures: #{failures.inspect}"
        end
      end
    end
  end

  describe "fail fixtures" do
    GbFixturesSpec::FAIL_FILES.each do |fixture_file|
      describe File.basename(fixture_file) do
        # The fail fixtures are hand-written plain inputs. The classifier's
        # `#input# ErrorClass: "message"` shape is read too, so a later
        # classification run needs no change here.
        let(:inputs) do
          recorded = read_fail_fixture_inputs(fixture_file)
          recorded.empty? ? read_fixture_file(fixture_file) : recorded
        end

        it "rejects every recorded input" do
          accepted = inputs.reject do |input|
            Pubid::Gb.parse(input)
            false
          rescue Parslet::ParseFailed, Pubid::Errors::Error
            true
          end

          expect(accepted).to be_empty,
                              "unexpectedly parsed: #{accepted.inspect}"
        end
      end
    end
  end
end
