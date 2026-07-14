# frozen_string_literal: true

require "spec_helper"

# Round-trip every real identifier in the pass fixtures: parse each line and
# assert it renders back to the exact printed form (4-digit zero padding
# preserved).
RSpec.describe "XSF Fixture Round-trip" do
  include FixtureFileHelper

  fixture_dir = File.join(__dir__, "../../fixtures/xsf/identifiers/pass")

  Dir.glob(File.join(fixture_dir, "*.txt")).each do |fixture_file|
    describe File.basename(fixture_file) do
      it "parses and round-trips every identifier" do
        read_fixture_file(fixture_file).each do |ref|
          expect(Pubid::Xsf.parse(ref).to_s).to eq(ref)
        end
      end
    end
  end
end
