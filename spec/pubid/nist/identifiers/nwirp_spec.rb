require "spec_helper"

# NWIRP is a low-volume simple NIST series routed to the Identifiers::Base
# fallback. The hand-off gave no concrete identifier, so a generic number is
# used to pin down parse + round-trip.
RSpec.describe "NIST NWIRP series" do
  describe ".parse" do
    describe "NIST NWIRP 1" do
      subject { "NIST NWIRP 1" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "parses as a NIST identifier" do
        expect(parsed).to be_a(Pubid::Nist::Identifier)
      end

      it "parses series" do
        expect(parsed.series.to_s).to eq("NWIRP")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
