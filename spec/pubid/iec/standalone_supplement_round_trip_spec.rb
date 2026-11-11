# frozen_string_literal: true

# A STANDALONE supplement is written without the document it supplements
# ("IEC/FDAM 60038-1"): the builder synthesises a bare SingleIdentifier base
# that carries the base number, and the supplement keeps its own number.
#
# The parse path and the from_hash path used to build that synthetic base
# differently. `ensure_base` gave it an IS/undated typed_stage, which has no
# code and so is never serialized, while `from_hash` rebuilt it with none. Every
# reader (to_s, to_urn, to_hash, #hash) agreed, but `==` compares `base` too,
# so a parsed reference never matched the same document loaded from an index
# row — `#matches?` returned false, with no error.
RSpec.describe "IEC standalone supplement round trip" do
  standalone = {
    "IEC/FDAM 60038-1" => Pubid::Iec::Identifiers::Amendment,
    "IEC/DCOR 60038-1:2019" => Pubid::Iec::Identifiers::Corrigendum,
    "IEC/DISH 60038-1" => Pubid::Iec::Identifiers::InterpretationSheet,
    "IEC/FDAM 60038-1-2:2020" => Pubid::Iec::Identifiers::Amendment,
    # The canonical spelling (what to_s prints) reaches a different grammar
    # branch than the slash spelling, so it is not built by the standalone
    # branch of Builder#build.
    "IEC FDAM 60038-1" => Pubid::Iec::Identifiers::Amendment,
    "IEC DISH 60038-1:2020" => Pubid::Iec::Identifiers::InterpretationSheet,
    # The self-base form: no base number, the supplement number alone.
    "IEC/AMD 1:2017" => Pubid::Iec::Identifiers::Amendment,
  }.freeze

  standalone.each do |input, klass|
    context input do
      let(:id) { Pubid::Iec.parse(input) }
      let(:back) { Pubid::Iec::Identifier.from_hash(id.to_hash) }

      it "parses to #{klass.name.split('::').last} with a synthetic base" do
        expect(id).to be_a(klass)
        expect(id.synthetic_base?).to be true
        expect(back.synthetic_base?).to be true
      end

      # Both halves together: an equal pair must share a hash, and the pair
      # must actually be equal, so the two can never diverge again.
      it "is == and hash-equal to its from_hash(to_hash) round trip" do
        expect(back).to eq(id)
        expect(back.hash).to eq(id.hash)
      end

      it "matches its round trip, also with the year ignored" do
        expect(id.matches?(back)).to be true
        expect(id.matches?(back, ignore: [:year])).to be true
      end

      it "renders and serializes the same on both paths" do
        expect(back.to_s).to eq(id.to_s)
        expect(back.to_urn.to_s).to eq(id.to_urn.to_s)
        expect(back.to_hash).to eq(id.to_hash)
      end

      # The parse path used to keep the base number in @number and the
      # supplement number in @part, with reader overrides swapping them; the
      # from_hash path stored the reader values. One layout now, read by `==`
      # and by every reader alike.
      it "stores the same number/part on both paths" do
        ivars = %i[@number @part @subpart]
        ivars.each do |ivar|
          expect(id.instance_variable_get(ivar))
            .to eq(back.instance_variable_get(ivar)), "#{ivar} differs"
        end
      end

      it "keeps the standalone form after #exclude" do
        expect(id.exclude(:year).synthetic_base?).to be true
        expect(id.exclude(:year).to_s).not_to include("/")
      end

      # Each reader is asked of a FRESH parse, first: the answer must not
      # depend on which reader happened to synthesise the base.
      it "gives the same answers whichever reader runs first" do
        rendered = Pubid::Iec.parse(input).tap(&:to_s)

        expect(Pubid::Iec.parse(input).number).to eq(rendered.number)
        expect(Pubid::Iec.parse(input).part).to eq(rendered.part)
        expect(Pubid::Iec.parse(input).to_mr_string)
          .to eq(rendered.to_mr_string)
        expect(Pubid::Iec.parse(input).exclude(:date).to_s)
          .to eq(rendered.exclude(:date).to_s)
        expect(Pubid::Iec.parse(input).exclude(:date).to_hash)
          .to eq(rendered.exclude(:date).to_hash)
        expect(rendered.matches?(Pubid::Iec.parse(input), ignore: [:date]))
          .to be true
      end
    end
  end

  it "stores the supplement number in number and the base number on base" do
    id = Pubid::Iec.parse("IEC/FDAM 60038-1")

    expect(id.instance_variable_get(:@number)).to eq("1")
    expect(id.instance_variable_get(:@part)).to be_nil
    expect(id.base.number).to eq("60038")
    expect(id.to_s).to eq("IEC FDAM 60038-1")
  end

  it "leaves an attached supplement's base alone" do
    id = Pubid::Iec.parse("IEC 60038-1/AMD1:2005")

    expect(id.synthetic_base?).to be false
    expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
  end
end
