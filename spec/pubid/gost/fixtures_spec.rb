# frozen_string_literal: true

require "spec_helper"
require "pubid/gost"

RSpec.describe "GOST fixture files" do
  fixture_dir = File.expand_path("../../fixtures/gost", __dir__)
  fixture_files = Dir[File.join(fixture_dir, "*.txt")].sort

  fixture_files.each do |path|
    file_name = File.basename(path)
    identifiers = File.readlines(path, encoding: "UTF-8")
                      .map(&:strip)
                      .reject { |l| l.empty? || l.start_with?("#") }

    describe file_name do
      identifiers.each do |id_str|
        it "parses #{id_str.inspect}" do
          expect { Pubid::Gost.parse(id_str) }.not_to raise_error
        end

        it "round-trips #{id_str.inspect}" do
          parsed = Pubid::Gost.parse(id_str)
          rendered = parsed.to_s
          # First parse normalizes Cyrillic → Latin. The round-trip
          # check is: render → parse → render must be idempotent.
          reparsed = Pubid::Gost.parse(rendered)
          expect(reparsed.to_s).to eq(rendered),
                                   -> { "#{rendered.inspect} did not round-trip (got #{reparsed.to_s.inspect})" }
        end
      end
    end
  end
end
