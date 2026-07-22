require "spec_helper"

# CHIPS is a simple NIST series (CHIPS Act R&D program) with no dedicated
# identifier class; it routes to the Identifier (base) fallback. Its number
# carries a hyphenated compound form (e.g. "1400-3"), like SP "800-53".
RSpec.describe "NIST CHIPS series" do
  describe ".parse" do
    describe "NIST CHIPS 1400-3" do
      subject { "NIST CHIPS 1400-3" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "parses as a NIST identifier" do
        expect(parsed).to be_a(Pubid::Nist::Identifier)
      end

      it "parses publisher" do
        expect(parsed.publisher.to_s).to eq("NIST")
      end

      it "parses series" do
        expect(parsed.series.to_s).to eq("CHIPS")
      end

      it "keeps the hyphen in the compound number" do
        expect(parsed.number.value).to eq("1400-3")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders the mr form" do
        expect(parsed.to_s(:mr)).to eq("NIST.CHIPS.1400-3")
      end
    end

    describe "NIST CHIPS 1100-1" do
      subject { "NIST CHIPS 1100-1" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "parses series" do
        expect(parsed.series.to_s).to eq("CHIPS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
