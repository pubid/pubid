# frozen_string_literal: true

require "spec_helper"

module IecFixturesSpec
  # This spec used to read a single file out of `archived-gems/pubid-iec/` and
  # gate on an 80% pass rate, with an empty failure-reporting block. So the
  # generated corpus under `spec/fixtures/iec/` was guarded by nothing, and 35
  # `pass/` entries had gone stale unnoticed. It now reads the generated tree,
  # at zero tolerance, on the shape of `spec/pubid/csa/fixtures_spec.rb`.
  #
  # `__dir__` is spec/pubid/iec, so the fixtures are two levels up, and the
  # flavor directory is lowercase.
  FIXTURES_DIR = File.expand_path("../../fixtures/iec/identifiers", __dir__)

  PASS_FILES = Dir.glob(File.join(FIXTURES_DIR, "pass", "*.txt")).freeze
  FAIL_FILES = Dir.glob(File.join(FIXTURES_DIR, "fail", "*.txt")).freeze
  # Unlike CSA, IEC's full/ holds many source files, not one identifiers.txt.
  # `classify_fixtures.rb#collect_all_identifiers` globs all of them, so the
  # conservation check must union them the same way.
  FULL_FILES = Dir.glob(File.join(FIXTURES_DIR, "full", "*.txt")).freeze
end

RSpec.describe "IEC fixture round-trip" do
  include FixtureFileHelper

  def passing_inputs
    IecFixturesSpec::PASS_FILES.flat_map do |file|
      read_pass_fixture_entries(file).map(&:first)
    end
  end

  def failing_inputs
    IecFixturesSpec::FAIL_FILES.flat_map do |file|
      read_fail_fixture_inputs(file)
    end
  end

  # The tripwire. Every example below is generated from a glob, so a wrong path
  # yields zero examples and zero failures. This example fails instead.
  it "finds the generated fixture files" do
    expect(IecFixturesSpec::PASS_FILES).not_to be_empty
    expect(IecFixturesSpec::FAIL_FILES).not_to be_empty
    expect(IecFixturesSpec::FULL_FILES).not_to be_empty
  end

  IecFixturesSpec::PASS_FILES.each do |fixture_file|
    describe "pass/#{File.basename(fixture_file)}" do
      it "parses every identifier and renders it as recorded" do
        entries = read_pass_fixture_entries(fixture_file)
        expect(entries).not_to be_empty

        failures = entries.filter_map do |input, expected|
          rendered = Pubid::Iec.parse(input).to_s
          if rendered == expected
            nil
          else
            { input: input, expected: expected, rendered: rendered }
          end
        rescue StandardError, Parslet::ParseFailed => e
          { input: input, expected: expected,
            error: "#{e.class}: #{e.message}" }
        end

        expect(failures).to be_empty,
                            "IEC pass fixtures did not round-trip: " \
                            "#{failures.first(10).inspect}"
      end
    end
  end

  IecFixturesSpec::FAIL_FILES.each do |fixture_file|
    describe "fail/#{File.basename(fixture_file)}" do
      it "rejects every identifier" do
        inputs = read_fail_fixture_inputs(fixture_file)
        expect(inputs).not_to be_empty

        accepted = inputs.select do |input|
          Pubid::Iec.parse(input)
          true
        rescue StandardError, Parslet::ParseFailed
          false
        end

        expect(accepted).to be_empty,
                            "recorded as unparseable but now parses: " \
                            "#{accepted.inspect}"
      end
    end
  end

  # The conservation law. `classify_fixtures.rb` rebuilds pass/ and fail/ from
  # full/, so the two sides must account for exactly the same identifiers. A
  # half-written classification run, or a fixture hand-added to pass/ without
  # being added to full/ (which the next run would silently delete), breaks
  # this equality and nothing else does.
  it "classifies every identifier in full/, and no others" do
    # full/ carries the `!input!rendered` marker too, so the input has to be
    # split out of it before comparing with pass/ and fail/, which store the
    # bare input.
    source = IecFixturesSpec::FULL_FILES.flat_map do |file|
      read_pass_fixture_entries(file).map(&:first)
    end

    expect((passing_inputs + failing_inputs).uniq.sort).to eq(source.uniq.sort)
  end

  # Uniquing the union above would absorb an identifier recorded on both sides,
  # so the partition is asserted separately.
  it "records no identifier as both passing and failing" do
    expect(passing_inputs & failing_inputs).to be_empty
  end
end
