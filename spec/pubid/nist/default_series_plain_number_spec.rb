# frozen_string_literal: true

# The default-series plain-number branch (pubid#711). A citation shaped
# like the docnumber — "800-90B", the docid-derived citation face of
# NIST.SP.800-90B — and its publisher-led spelling "NIST 800-90B" carry
# no series token; the grammar's trailing alternatives accept them and
# the Builder defaults the identity onto the SP series, so the parse is
# == to the spelled "NIST SP 800-90B" form a relaton lookup compares
# against. The bare face keeps the unspelled publisher suppressed
# (publisher_was_parsed: false, the #704 shape).
RSpec.describe "NIST default-series plain-number forms" do
  def parse(str)
    Pubid::Nist::Identifier.parse(str)
  end

  {
    "800-90B" => "SP 800-90B",
    "800-53" => "SP 800-53",
    "NIST 800-90B" => "NIST SP 800-90B",
    "NIST 800-53" => "NIST SP 800-53",
  }.each do |input, rendered|
    context input.inspect do
      subject(:plain) { parse(input) }

      it "parses onto the SpecialPublication identity" do
        expect(plain).to be_a(Pubid::Nist::Identifiers::SpecialPublication)
        expect(plain.series.value).to eq("SP")
        # The docnumber face: number + glued part letter ("800-90" + "B").
        expect("#{plain.number}#{plain.part}").to eq(input.sub(/\ANIST /, ""))
      end

      it "renders the default-series face" do
        expect(plain.to_s).to eq(rendered)
      end

      it "is == to the spelled NIST SP form" do
        spelled = parse("NIST SP #{input.sub(/\ANIST /, '')}")
        expect(plain).to eq(spelled)
        expect(spelled).to eq(plain)
      end

      it "carries the NIST publisher the series implies" do
        expect(plain.publisher).to eq("NIST")
        expect(plain.publisher_was_parsed).to eq(input.start_with?("NIST "))
      end
    end
  end

  # The owner's repro (issue #711): the plain citation face parses, and
  # the docnumber spelling converges on the same identity — same URN,
  # same MR string, same hash but for the equality-ignored
  # publisher_was_parsed spelling flag.
  it "converges the docid-derived citation on the NIST.SP.800-90B identity" do
    spelled = parse("NIST SP 800-90B")
    docid = parse("NIST.SP.800-90B")
    bare = parse("800-90B")
    led = parse("NIST 800-90B")

    [bare, led].each do |plain|
      expect(plain).to eq(spelled)
      expect(plain).to eq(docid)
      expect(plain.to_urn).to eq(spelled.to_urn)
      expect(plain.to_mr_string).to eq("NIST.SP.800-90B")
      expect(plain.to_hash.reject { |k, _| k == "publisher_was_parsed" })
        .to eq(spelled.to_hash)
      expect(spelled.matches?(plain)).to be(true)
    end
  end

  it "parses the bare docnumber with the MR face of the DOI surface" do
    bare = parse("800-90B")
    expect(bare.to_s).to eq("SP 800-90B")
    # The MR face always carries the publisher (the DOI face style); the
    # bare docnumber parse lands on the exact "NIST.SP.800-90B" surface
    # relaton-data-nist stores for the document.
    expect(bare.to_mr_string).to eq("NIST.SP.800-90B")
    expect(bare.to_s(with_publisher: false)).to eq("SP 800-90B")
  end

  it "round-trips the bare parse through from_hash and the pubid URN" do
    bare = parse("800-90B")
    expect(Pubid::Nist::Identifier.from_hash(bare.to_hash)).to eq(bare)
    expect(Pubid.parse_urn(bare.to_pubid_urn).to_hash).to eq(bare.to_hash)
  end

  # The number families ride the same report-number tail as the
  # series-bearing branches: edition/part/stage tails decode identically.
  it "decodes the number tails on the default series" do
    expect(parse("800-90B(e2018)").number).to eq("800-90")
    expect(parse("NIST 800-53r5").to_s).to eq("NIST SP 800-53r5")
    expect(parse("800-90B 2pd").to_s).to eq("SP 800-90B 2pd")
    expect(parse("800-53A").part.value).to eq("A")
  end

  # The dated alternative keeps priority over the default-series branch:
  # the dataset's "NIST 2022-04-15 001" rows stay DatedDocument.
  it "leaves the publisher-led dated rows on the dated branch" do
    dated = parse("NIST 2023-04-15 001")
    expect(dated).to be_a(Pubid::Nist::Identifiers::DatedDocument)
    expect(dated.dated_seq).to eq("001")
  end

  # The routing probe must keep failing: a grammar that accepted the
  # arbitrary slug would be disqualified as a Pubid.parse fallback.
  # (Pubid::ROUTING_PROBE, private — spelled out here.)
  it "does not accept the routing probe" do
    expect { Pubid::Nist.parse("zzqx-nonsense-9714") }
      .to raise_error(Pubid::Errors::ParseError)
  end
end
