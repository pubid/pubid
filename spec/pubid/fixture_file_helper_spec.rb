# frozen_string_literal: true

require "spec_helper"

# Fixture files legitimately contain non-ASCII bytes (e.g. em/en dashes).
# Reading them with File.read/readlines depends on Encoding.default_external,
# which is the process locale (LANG/LC_ALL) unless spec_helper forces it —
# US-ASCII in a locale-less container, which raises
# Encoding::CompatibilityError the moment such a byte is read.
RSpec.describe FixtureFileHelper do
  include FixtureFileHelper

  it "forces UTF-8 as the default external encoding" do
    expect(Encoding.default_external).to eq(Encoding::UTF_8)
  end

  it "reads a fixture file containing non-ASCII bytes without raising" do
    expect do
      read_fixture_file("spec/fixtures/gb/pass/social_group.txt")
    end.not_to raise_error
  end
end
