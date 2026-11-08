# frozen_string_literal: true

# The bare compound series is the SERIES REFERENCE identity (owner ruling
# on the relaton fuzz gate's "NBS CS" mutant): the bare abbreviation of a
# named NBS/NIST series parses with number/edition nil, rendering the
# canonical short face (the abbreviation) and the v1 series.yaml MR face.
# The seed table is the archived v1 repo's series.yaml (pubid/pubid-nist):
#   CS = Commercial Standards, CSM = Commercial Standards Monthly,
#   CIS = Consumer Information Series, CS-E = Commercial Standards
#   (emergency) — the same partial/bare-reference pattern as BIPM's
#   "SI Brochure".
RSpec.describe "bare compound series (the series reference)" do
  # [input, class, human, mr]
  {
    "NBS CS" => [Pubid::Nist::Identifiers::CommercialStandard,
                 "NBS CS", "NBS.CS"],
    "NBS CSM" => [Pubid::Nist::Identifiers::CommercialStandardsMonthly,
                  "NBS CSM", "NBS.CSM"],
    "NBS CS-E" => [Pubid::Nist::Identifiers::CommercialStandardEmergency,
                   "NBS CS-E", "NBS.CS-E"],
    "NBS CIS" => [Pubid::Nist::Identifier, "NBS CIS", "NBS.CIS"],
    "NIST PS" => [Pubid::Nist::Identifier, "NIST PS", "NIST.PS"],
    "NIST DCI" => [Pubid::Nist::Identifier, "NIST DCI", "NIST.DCI"],
  }.each do |input, (klass, human, mr)|
    describe input do
      let(:parsed) { Pubid::Nist.parse(input) }

      it "parses as the series' identifier class" do
        expect(parsed).to be_a(klass)
      end

      it "carries no number (the series-reference shape)" do
        expect(parsed.number).to be_nil
      end

      it "carries no edition" do
        expect(parsed.edition).to be_nil
      end

      it "renders the canonical short face" do
        expect(parsed.to_s).to eq(human)
      end

      it "renders the v1 series.yaml MR face" do
        expect(parsed.to_mr_style).to eq(mr)
      end

      it "round-trips through the serialized hash" do
        expect(Pubid::Nist::Identifier.from_hash(parsed.to_hash)).to eq(parsed)
      end

      it "round-trips through the pubid-scheme URN" do
        expect(Pubid.parse_urn(parsed.to_pubid_urn).to_hash)
          .to eq(parsed.to_hash)
      end
    end
  end

  describe "the series reference as a wildcard query" do
    # The relaton lookup use: a partial reference matches every
    # edition/number of the series (NIST #matches? treats unset parts as
    # wildcards on the same class).
    it "matches the editioned and numbered members of the series" do
      query = Pubid::Nist.parse("NBS CS")
      expect(query.matches?(Pubid::Nist.parse("NBS CS e15"))).to be(true)
      expect(query.matches?(Pubid::Nist.parse("NBS CS 102"))).to be(true)
      expect(query.matches?(Pubid::Nist.parse("NBS CSM v6n1"))).to be(false)
    end
  end

  describe "the editioned and numbered forms parse unchanged" do
    # The grammar change makes the compound-series tail optional; every
    # previously accepted form must keep parsing byte-identically.
    {
      "NBS CS e15" => "NBS CS e15",
      "NBS CS 102" => "NBS CS 102",
      "NBS CS 100-45" => "NBS CS 100-45",
      "NBS CS 123e2-50" => "NBS CS 123e2.1950",
      "NBS CS e104" => "NBS CS-E 104",
      "NBS CSM v6n1" => "NBS CSM v6n1",
      "NBS CIS 3" => "NBS CIS 3",
      "NIST SP 800-53" => "NIST SP 800-53",
      "NBS CIRC 25sup1924" => "NBS CIRC 25sup1924",
    }.each do |input, human|
      describe input do
        it "renders byte-identically" do
          expect(Pubid::Nist.parse(input).to_s).to eq(human)
        end
      end
    end
  end
end
