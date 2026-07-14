# frozen_string_literal: true

require "spec_helper"

RSpec.describe "OGC fixture round-trip" do
  include FixtureFileHelper

  let(:pass_file) do
    File.join(__dir__, "../../fixtures/ogc/identifiers/pass/document.txt")
  end

  let(:fail_file) do
    File.join(__dir__, "../../fixtures/ogc/identifiers/fail/document.txt")
  end

  it "parses and round-trips every identifier in the pass fixtures" do
    identifiers = read_fixture_file(pass_file)
    expect(identifiers).not_to be_empty

    failures = identifiers.reject do |pubid|
      Pubid::Ogc.parse(pubid).to_s == pubid
    rescue StandardError => e
      warn "OGC fixture error for #{pubid.inspect}: #{e.class}: #{e.message}"
      false
    end

    expect(failures).to be_empty,
                        "non-round-tripping OGC ids: #{failures.inspect}"
  end

  it "rejects every identifier in the fail fixtures" do
    malformed = read_fixture_file(fail_file)
    expect(malformed).not_to be_empty

    accepted = malformed.select do |pubid|
      Pubid::Ogc.parse(pubid)
      true
    rescue StandardError
      false
    end

    expect(accepted).to be_empty,
                        "unexpectedly parsed malformed ids: #{accepted.inspect}"
  end
end
