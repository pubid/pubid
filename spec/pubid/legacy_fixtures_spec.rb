# frozen_string_literal: true

require "spec_helper"

# The v1 fixture files came from the standalone gems under `archived-gems/`.
# That folder is gone. The specs that still read those files now read verbatim
# copies under `spec/fixtures/legacy/<flavor>/`.
#
# The copies under `identifiers/full/` are NOT a substitute: they are classifier
# inputs and hold normalizing forms, so the round-trip thresholds fail on them.
#
# The copies must NOT sit inside a flavor directory. Several corpus sweeps glob
# `spec/fixtures/<flavor>/**/*.txt` (the root_number specs,
# `ieee/wrapper_root_number_spec.rb`). A `spec/fixtures/ieee/legacy/` folder fed
# the raw v1 lines to the IEEE sweep and broke its slug and URN checks.
module LegacyFixturesSpec
  FIXTURES_DIR = File.expand_path("../fixtures", __dir__)
  LEGACY_DIR = File.join(FIXTURES_DIR, "legacy")
  REPO_ROOT = File.expand_path("../..", __dir__)

  # The files each reader needs. Keep this table in step with the readers.
  FILES = {
    "iso" => %w[
      iso-pubid-basic.txt iso-pubid-cd.txt iso-pubid-coramd.txt
      iso-pubid-directives.txt iso-pubid-draft-amd-cor.txt
      iso-pubid-french.txt iso-pubid-languages.txt iso-pubid-legacy-tr-ts.txt
      iso-pubid-supplement-iteration.txt iwa-pubid.txt
    ],
    "jis" => %w[jis-pubids.txt],
    "ieee" => %w[pubid-to-parse.txt unapproved.txt pubid-parsed.txt],
    "iec" => %w[
      csv-pubid.txt iec-pubid.txt iecee-trf-pubid.txt iecex-trf-pubid.txt
      iecq-pubid.txt ish-pubid.txt iso-iec-pubid.txt sheets-pubid.txt
      tc1-pubid.txt tr-pubid.txt ts-pubid.txt vap-pubid.txt
      wd-special-groups.txt working-documents.txt working-programmes.txt
    ],
  }.freeze

  # Code that runs in the suite or ships in the gem. The one-shot migration
  # scripts under spec/fixtures/ are not in this list.
  CODE_GLOBS = %w[
    lib/**/*.rb lib/tasks/*.rake Rakefile
    spec/pubid/**/*.rb spec/integration/**/*.rb spec/support/**/*.rb
    spec/spec_helper.rb
  ].freeze
end

RSpec.describe "Legacy v1 fixtures" do
  LegacyFixturesSpec::FILES.each do |flavor, names|
    names.each do |name|
      it "has spec/fixtures/legacy/#{flavor}/#{name}" do
        path = File.join(LegacyFixturesSpec::LEGACY_DIR, flavor, name)

        expect(File.file?(path)).to be(true), "missing #{path}"
        expect(File.size(path)).to be_positive
      end
    end
  end

  it "keeps no legacy folder inside a flavor directory" do
    nested = Dir.glob(File.join(LegacyFixturesSpec::FIXTURES_DIR, "*",
                                "**", "legacy"))
      .select { |path| File.directory?(path) }
      .map { |path| path.delete_prefix("#{LegacyFixturesSpec::FIXTURES_DIR}/") }

    expect(nested).to eq([])
  end

  it "has no code that reads the deleted archived-gems folder" do
    root = LegacyFixturesSpec::REPO_ROOT
    files = LegacyFixturesSpec::CODE_GLOBS.flat_map do |glob|
      Dir.glob(File.join(root, glob))
    end
    # This file names the folder on purpose.
    files = files.uniq - [__FILE__]

    offenders = files.flat_map do |file|
      File.readlines(file).each_with_index.filter_map do |line, index|
        next if line.lstrip.start_with?("#")
        next unless line.include?("archived-gems")

        "#{file.delete_prefix("#{root}/")}:#{index + 1}"
      end
    end

    expect(offenders).to eq([])
  end

  describe FixtureLoader do
    include FixtureLoader

    it "reads a legacy fixture" do
      expect(load_legacy_fixture(:iec, "tr-pubid.txt")).not_to be_empty
    end

    # A missing file used to return [], so a whole context tested nothing and
    # passed. A missing file must fail loudly.
    it "raises for a missing legacy fixture" do
      expect { load_legacy_fixture(:iec, "no-such-file.txt") }
        .to raise_error(Errno::ENOENT)
    end
  end
end
