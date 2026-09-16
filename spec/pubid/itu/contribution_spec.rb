# frozen_string: true

require "spec_helper"

# pubid#340: ITU Temporary Document (contribution) identifiers, mirroring
# pubid-itu 1.15's Pubid::Itu::Identifier::Contribution. metanorma-itu
# builds these from :doctype: contribution documents and had to carry a
# flavor-local render override; upstream, the type parses, renders,
# round-trips and is reachable through Pubid::Itu.locate_type.
RSpec.describe "ITU Contribution (Temporary Document) — issue #340" do
  subject(:klass) { Pubid::Itu::Identifier }

  {
    "ITU-R SG17-C1000" => "ITU-R SG17-C1000",
    "ITU-T SG17-C1000" => "ITU-T SG17-C1000",
    "ITU-T SG17-C1000-E" => "ITU-T SG17-C1000-E",
  }.each do |input, expected|
    context input.inspect do
      it "renders as #{expected.inspect}" do
        expect(klass.parse(input).to_s).to eq(expected)
      end

      it "is a Contribution" do
        expect(klass.parse(input))
          .to be_a(Pubid::Itu::Identifiers::Contribution)
      end

      it "round-trips through to_hash/from_hash" do
        id = klass.parse(input)
        expect(klass.from_hash(id.to_hash)).to eq(id)
      end

      it "keys the index on a non-empty root number" do
        expect(klass.parse(input).root.number.to_s).to eq(
          input[/C(\d+)/, 1],
        )
      end
    end
  end

  it "keeps the series-code documents on their own route" do
    # "ITU-T EMC-5" is a series-code document, not a contribution: the -C
    # marker (C + digits) is what distinguishes the two dash shapes.
    expect(Pubid::Itu.parse("ITU-T EMC-5"))
      .to be_a(Pubid::Itu::Identifiers::Recommendation)
  end

  describe "Pubid::Itu.locate_type" do
    it "finds the contribution type" do
      expect(Pubid::Itu.locate_type("contribution"))
        .to eq(Pubid::Itu::Identifiers::Contribution)
    end

    it "finds every concrete leaf by its derived key" do
      {
        "question" => Pubid::Itu::Identifiers::Question,
        "handbook" => Pubid::Itu::Identifiers::Handbook,
        "recommendation" => Pubid::Itu::Identifiers::Recommendation,
        "annex_of_recommendation" =>
          Pubid::Itu::Identifiers::AnnexOfRecommendation,
      }.each do |key, expected|
        expect(Pubid::Itu.locate_type(key)).to eq(expected)
      end
    end
  end
end
