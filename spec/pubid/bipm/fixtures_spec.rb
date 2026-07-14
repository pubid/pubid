# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BIPM fixture round-trip" do
  include FixtureFileHelper

  pass_dir = File.join(__dir__, "../../fixtures/bipm/identifiers/pass")

  let(:fail_file) do
    File.join(__dir__, "../../fixtures/bipm/identifiers/fail/invalid.txt")
  end

  Dir.glob(File.join(pass_dir, "*.txt")).each do |file|
    context File.basename(file) do
      it "parses and round-trips every identifier" do
        identifiers = read_fixture_file(file)
        expect(identifiers).not_to be_empty

        failures = identifiers.reject do |pubid|
          Pubid::Bipm.parse(pubid).to_s == pubid
        rescue StandardError => e
          warn "BIPM fixture error for #{pubid.inspect}: #{e.message}"
          false
        end

        expect(failures).to be_empty,
                            "non-round-tripping BIPM ids: #{failures.inspect}"
      end
    end
  end

  it "rejects every identifier in the fail fixtures" do
    malformed = read_fixture_file(fail_file)
    expect(malformed).not_to be_empty

    accepted = malformed.select do |pubid|
      Pubid::Bipm.parse(pubid)
      true
    rescue StandardError
      false
    end

    expect(accepted).to be_empty,
                        "unexpectedly parsed malformed ids: #{accepted.inspect}"
  end
end
