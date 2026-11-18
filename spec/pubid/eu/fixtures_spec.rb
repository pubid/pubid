# frozen_string_literal: true

require "spec_helper"

# The generated EU fixtures (spec/fixtures/eu/identifiers/{pass,fail}),
# rebuilt from full/identifiers.txt by `rake "validation:classify[eu]"`.
RSpec.describe "EU fixtures" do
  extend FixtureFileHelper
  include FixtureFileHelper

  root = File.expand_path("../../fixtures/eu/identifiers", __dir__)
  pass_files = Dir[File.join(root, "pass", "*.txt")].sort
  fail_files = Dir[File.join(root, "fail", "*.txt")].sort

  it "finds the fixture files" do
    expect(pass_files).not_to be_empty
    expect(fail_files).not_to be_empty
  end

  pass_files.each do |file|
    it "parses and renders every entry of pass/#{File.basename(file)}" do
      failures = read_pass_fixture_entries(file).reject do |input, rendered|
        Pubid::Eu.parse(input).to_s == rendered
      end
      expect(failures).to eq([])
    end
  end

  fail_files.each do |file|
    it "rejects every entry of fail/#{File.basename(file)}" do
      parsed = read_fail_fixture_inputs(file).select do |input|
        Pubid::Eu.parse(input)
      rescue Pubid::Errors::ParseError
        false
      end
      expect(parsed).to eq([])
    end
  end

  it "conserves the full/ inputs across pass/ and fail/" do
    full = read_fixture_file(File.join(root, "full", "identifiers.txt"))
    classified = pass_files.flat_map do |f|
      read_pass_fixture_entries(f).map(&:first)
    end +
      fail_files.flat_map { |f| read_fail_fixture_inputs(f) }
    expect(classified.sort).to eq(full.sort)
  end
end
