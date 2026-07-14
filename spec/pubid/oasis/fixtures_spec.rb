# frozen_string_literal: true

require "spec_helper"

# Bulk round-trip over hand-picked real identifiers from relaton-data-oasis.
# Every line must satisfy parse(x).to_s == x (100% — no pass-rate slack, since
# the verbatim `original` field guarantees the printed string is preserved even
# for the malformed records that decomposition cannot classify).
RSpec.describe "Pubid::Oasis fixtures round-trip" do
  fixture_glob = File.join(__dir__,
                           "../../fixtures/oasis/identifiers/pass/*.txt")

  Dir.glob(fixture_glob).each do |file|
    describe File.basename(file) do
      lines = File.readlines(file).map(&:strip)
        .reject { |l| l.empty? || l.start_with?("#") }

      lines.each do |pubid|
        it "round-trips #{pubid.inspect}" do
          expect(Pubid::Oasis.parse(pubid).to_s).to eq(pubid)
        end
      end
    end
  end
end
