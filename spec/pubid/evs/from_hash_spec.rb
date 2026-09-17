# frozen_string_literal: true

require "spec_helper"
require "yaml"

# pubid#383: attribute defaults must be component INSTANCES, never raw
# metadata symbols. lutaml materializes defaults during from_hash, and
# casting a Symbol into Components::Type raises InvalidFormatError - EVS
# and every IDF identifier class shared the
# `default: -> { self.class.type[:key] }` shape.
RSpec.describe "from_hash over defaulted type attributes" do
  it "round-trips every EVS adoption through from_hash" do
    [
      "EVS-EN 18216:2026",
      "EVS-EN ISO 9001:2015",
      "EVS-EN ISO/IEC 27017:2026",
    ].each do |ref|
      hash = Pubid::Evs.parse(ref).to_hash
      expect(Pubid::Evs::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end

  it "round-trips every IDF identifier class through from_hash" do
    repo = ENV.fetch(
      "PUBID_TESTSUITE_PATH",
      File.expand_path("../../../../pubid-testsuite", __dir__),
    )
    skip "pubid-testsuite corpus absent" unless File.directory?(File.join(repo, 
                                                                          "tests", "idf"))

    files = Dir[File.join(repo, "tests", "idf", "*.yaml")]
      .reject { |f| File.basename(f).start_with?("_") }
    rows = files.flat_map { |f| YAML.safe_load_file(f) }
    rows.each do |row|
      hash = Pubid::Idf.parse(row.dig("representations", "human")).to_hash
      expect(Pubid::Idf::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end

  it "declares no raw type[:key] symbol defaults" do
    pattern = /default: -> \{ self\.class\.type\[:key\] \}/
    offenders = Dir["lib/pubid/**/*.rb"].select do |path|
      pattern.match?(File.read(path))
    end
    expect(offenders).to be_empty,
                         "raw Symbol type defaults remain in: #{offenders.join(', ')}"
  end
end
