# frozen_string_literal: true

require "spec_helper"

# A BSI adoption wraps another flavor's document. It held that document in an
# attribute named `adopted`, which broke the cross-flavor contract three ways:
#
#   1. `#base` — the uniform parent accessor — was nil, so a consumer walking
#      `base` saw a leaf.
#   2. `#root` needed a hand-written override, and only one of the two classes
#      had it.
#   3. The `#number` / `#date` / `#part` / `#subpart` delegations that stood in
#      for the missing `#root` SHADOWED real lutaml accessors. They answered
#      with a value for a plain member and nil for a wrapped one, and they
#      re-emitted the nested document's number and part at the top level of
#      every wrapper row. (`#date` also made `to_hash` raise; pubid#379 fixed
#      that separately by widening the attribute type.)
#
# The attribute is now `base`, the delegations are gone, and every identity
# surface (URN, MR slug, index key) reads `#root` instead.
module AdoptionBaseSpec
  REFS = {
    "BS ISO 8601:2019" => Pubid::Bsi::Identifiers::AdoptedInternationalStandard,
    "BS EN 10077-1:2006" => Pubid::Bsi::Identifiers::AdoptedEuropeanNorm,
    "BS HD 60269-3" => Pubid::Bsi::Identifiers::AdoptedEuropeanNorm,
    "DD ENV ISO 11079:1999" => Pubid::Bsi::Identifiers::AdoptedEuropeanNorm,
    "NA to BS EN 1991-1-1:2002" => Pubid::Bsi::Identifiers::NationalAnnex,
  }.freeze

  # The three classes whose parent slot was renamed to `base` and whose
  # delegating readers were deleted.
  WRAPPERS = [
    Pubid::Bsi::Identifiers::AdoptedEuropeanNorm,
    Pubid::Bsi::Identifiers::AdoptedInternationalStandard,
    Pubid::Bsi::Identifiers::NationalAnnex,
  ].freeze

  # Every BSI type that wraps another document. None of them owns identity.
  ALL_WRAPPERS = (WRAPPERS + [
    Pubid::Bsi::Identifiers::AddendumDocument,
    Pubid::Bsi::Identifiers::BundledIdentifier,
    Pubid::Bsi::Identifiers::ConsolidatedIdentifier,
    Pubid::Bsi::Identifiers::ExpertCommentary,
    Pubid::Bsi::Identifiers::Set,
    Pubid::Bsi::Identifiers::SupplementDocument,
  ]).freeze

  # One reference per wrapper type, for the "owns no identity" contract.
  WRAPPER_REFS = {
    "BS EN 10077-1:2006" => "10077",
    "BS ISO 8601:2019" => "8601",
    "NA to BS EN 1991-1-1:2002" => "1991",
    "BS 1902-2.3:Addendum No. 1:1976" => "1902",
    "BS 2SP 68 to BS 2SP 71:1973" => "68",
    "BS HD 60269-2:2013+A1:2022" => "60269",
    "BS EN ISO 13485 Expert Commentary" => "13485",
    "BS ISO 20400 + BS ISO 44001+BS ISO 44002" => "20400",
    "BS 1000[9]:Supplement No. 1:1972" => "1000",
  }.freeze
end

RSpec.describe "BSI adoption wrappers hold the adopted document in `base`" do
  def parse(string)
    Pubid::Bsi.parse(string)
  end

  describe "the uniform accessor" do
    AdoptionBaseSpec::REFS.each do |ref, klass|
      it "#{ref} exposes the adopted document under #base" do
        id = parse(ref)
        expect(id).to be_a(klass)
        expect(id.base).to be_a(Pubid::Identifier)
      end

      it "#{ref} no longer answers to #adopted" do
        expect(parse(ref)).not_to respond_to(:adopted)
      end
    end
  end

  describe "#root reaches the origin document without an override" do
    it "walks one adoption layer" do
      id = parse("BS ISO 8601:2019")
      expect(id.root).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      expect(id.root.number.to_s).to eq("8601")
    end

    # DD ENV ISO 11079:1999 adopts a CEN EuropeanPrestandard, which is itself a
    # wrapper around the ISO standard. The old one-level #number delegation died
    # here; the inherited #root recurses.
    it "walks two adoption layers" do
      id = parse("DD ENV ISO 11079:1999")
      expect(id.root).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      expect(id.root.number.to_s).to eq("11079")
    end

    it "neither class defines its own #root any more" do
      AdoptionBaseSpec::WRAPPERS.each do |klass|
        expect(klass.instance_methods(false)).not_to include(:root)
      end
    end
  end

  # The rule the branch establishes, stated so a later reader does not mistake a
  # nil `#number` on a wrapper for a bug. Before this, the wrapper classes read
  # one level down, so the SAME accessor answered with the member's value when
  # that member was a plain standard and with nil when it was itself a wrapper.
  describe "a wrapper owns no identity; #root carries it" do
    AdoptionBaseSpec::WRAPPER_REFS.each do |ref, number|
      it "#{ref} keeps its number on #root, not on itself" do
        id = parse(ref)
        expect(id.number).to be_nil
        expect(id.root.number.to_s).to eq(number)
      end

      # This is what relaton-index keys its binary search on, so it is the one
      # value that may never be empty.
      it "#{ref} has a non-empty index key" do
        expect(parse(ref).root.number.to_s).not_to be_empty
      end
    end

    it "no wrapper class delegates an identity attribute one level down" do
      identity = %i[number part parts subpart date year]
      owned = AdoptionBaseSpec::ALL_WRAPPERS.to_h do |klass|
        [klass.name.split("::").last, klass.instance_methods(false) & identity]
      end
      expect(owned.reject { |_, v| v.empty? }).to eq({})
    end
  end

  describe "the shadowing delegations are gone" do
    # A method of the same name as a lutaml attribute moves the accessor's owner
    # onto the class, which is the determinism landmine CLAUDE.md records. None
    # of these four may be owned by an adoption class.
    %i[number date part subpart].each do |attr|
      AdoptionBaseSpec::WRAPPERS.each do |klass|
        it "#{klass.name.split('::').last} has no #{attr} method" do
          expect(klass.instance_methods(false)).not_to include(attr)
        end
      end
    end
  end

  describe "#to_hash" do
    AdoptionBaseSpec::REFS.each_key do |ref|
      it "#{ref} serializes without raising" do
        expect { parse(ref).to_hash }.not_to raise_error
      end

      it "#{ref} keys the adopted document as `base`, never `adopted`" do
        hash = parse(ref).to_hash
        expect(hash).to have_key("base")
        expect(hash).not_to have_key("adopted")
      end

      # The delegations re-emitted the nested document's identity at the top
      # level, so every adoption row carried its number and part twice.
      it "#{ref} does not duplicate the nested identity at the top level" do
        hash = parse(ref).to_hash
        expect(hash.keys).not_to include("number", "part", "subpart", "year")
      end

      it "#{ref} round-trips through from_hash" do
        id = parse(ref)
        expect(Pubid::Bsi::Identifier.from_hash(id.to_hash)).to eq(id)
      end
    end
  end

  describe "the printed identifier is unchanged" do
    {
      "BS ISO 8601:2019" => "BS ISO 8601:2019",
      "BS EN 10077-1:2006" => "BS EN 10077-1:2006",
      "BS HD 60269-3" => "BS HD 60269-3",
      "DD ENV ISO 11079:1999" => "DD ENV ISO 11079:1999",
    }.each do |ref, rendered|
      it "#{ref} renders as #{rendered}" do
        expect(parse(ref).to_s).to eq(rendered)
      end
    end
  end

  describe "the identity surfaces read #root" do
    # The URN generator read the delegations for part, subpart and date. It now
    # falls back to #root, as it already did for the number.
    {
      "BS EN 10077-1:2006" => "urn:bsi:bs:10077:-1:2006",
      "BS ISO 8601:2019" => "urn:bsi:bs:8601:2019",
      "BS HD 60269-3" => "urn:bsi:bs:60269:-3",
    }.each do |ref, urn|
      it "#{ref} keeps its URN" do
        expect(parse(ref).to_urn).to eq(urn)
      end
    end

    # The one-level delegation left this URN with no year at all, so every
    # edition of the document collided on urn:bsi:dd:11079.
    it "DD ENV ISO 11079:1999 gains the publication year its URN was missing" do
      expect(parse("DD ENV ISO 11079:1999").to_urn)
        .to eq("urn:bsi:dd:11079:1999")
    end

    # The first three keep the slug they already had. The last four had none:
    # before the RootIdentity hooks, 158 BSI identifiers slugged the bare "bs",
    # and `to_slug` is an output FILENAME, so that is 158 documents overwriting
    # each other. One entry per class that collapsed.
    {
      "BS EN 10077-1:2006" => "bs.10077-1.2006",
      "BS ISO 8601:2019" => "bs.8601.2019",
      "BS HD 60269-3" => "bs.60269-3",
      "BS HD 60269-2:2013+A1:2022" => "bs.60269-2.2013",
      "BS EN ISO 13485 Expert Commentary" => "bs.13485",
      # The wrapped BS 1902-2.3 carries no year of its own, so the slug has
      # none either — the addendum's own 1976 is not the document's edition.
      "BS 1902-2.3:Addendum No. 1:1976" => "bs.1902-2.3",
      "NA to BS EN 1991-1-1:2002" => "bs.1991-1-1.2002",
    }.each do |ref, slug|
      it "#{ref} slugs as #{slug}" do
        expect(parse(ref).to_mr_string).to eq(slug)
      end
    end
  end

  # An attached amendment held its ordinal and year under private names while
  # the `number` and `year` it could use stayed unused. Renaming them makes an
  # amendment row read like every other BSI row.
  describe "an attached amendment keys its ordinal as `number`" do
    let(:amendment) do
      parse("BS 4592-0:2006+A1:2012").identifiers[1]
    end

    it "is an Amendment carrying number and year" do
      expect(amendment).to be_a(Pubid::Bsi::Identifiers::Amendment)
      expect(amendment.number).to eq("1")
      expect(amendment.year).to eq("2012")
    end

    it "serializes as number/year, not amendment_number/amendment_year" do
      hash = amendment.to_hash
      expect(hash).to include("number" => "1", "year" => "2012")
      expect(hash.keys).not_to include("amendment_number", "amendment_year")
    end

    # `supplement_type` is kept: nothing else says which supplement class this
    # is, and relaton detects a supplement with `respond_to?(:supplement_type)`.
    # `supplement_number` / `supplement_year` were one-line aliases for
    # `number` / `year` and are gone.
    it "keeps supplement_type and reads the ordinal from number/year" do
      expect(amendment.supplement_type).to eq(:amendment)
      expect(amendment).not_to respond_to(:supplement_number)
      expect(amendment).not_to respond_to(:supplement_year)
    end

    # The ordinal is NOT a document number: `#root` walks `base` to the amended
    # standard, which is what relaton-index keys on.
    it "does not let the ordinal become the index key" do
      expect(amendment.number).to eq("1")
      expect(amendment.root.number.to_s).to eq("4592")
      expect(parse("BS 4592-0:2006+A1:2012").root.number.to_s).to eq("4592")
    end

    # The year is a declared attribute rather than the inherited `date`,
    # because `#exclude` recurses into nested identifiers: holding it in `date`
    # made `exclude(:date)` drop the amendment's year along with the standard's.
    it "survives exclude(:date), which drops only the standard's date" do
      expect(parse("BS 7273-4:2015+A1:2021").exclude(:date).to_s)
        .to eq("BS 7273-4+A1:2021")
    end

    it "renders and round-trips unchanged" do
      id = parse("BS 4592-0:2006+A1:2012")
      expect(id.to_s).to eq("BS 4592-0:2006+A1:2012")
      expect(id.to_urn).to eq("urn:bsi:bs:4592:-0:2006:amd:1:2012")
      expect(Pubid::Bsi::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  # The same conversion on the sibling class. There are 0 corrigendum objects in
  # the BSI pass fixtures, so unlike the amendment this cannot be measured
  # against the corpus — these examples are the whole net.
  describe "an attached corrigendum keys its ordinal as `number`" do
    def corrigendum_in(ref)
      parse(ref).identifiers.last
    end

    it "carries number and year, as a String" do
      cor = corrigendum_in("BS 1234:2015+C1:2016")
      expect(cor).to be_a(Pubid::Bsi::Identifiers::Corrigendum)
      expect(cor.number).to eq("1")
      expect(cor.year).to eq("2016")
    end

    it "serializes as number/year, not corrigendum_number/corrigendum_year" do
      hash = corrigendum_in("BS 1234:2015+C1:2016").to_hash
      expect(hash).to include("number" => "1", "year" => "2016")
      expect(hash.keys).not_to include("corrigendum_number", "corrigendum_year")
    end

    # A caller that reads `number` / `year` must get the same types whichever
    # supplement class it holds — that is what made the aliases deletable.
    it "carries number and year with the same types as Amendment" do
      cor = corrigendum_in("BS 1234:2015+C1:2016")
      amd = parse("BS 7273-4:2015+A1:2021").identifiers.last
      expect(cor.supplement_type).to eq(:corrigendum)
      expect(amd.supplement_type).to eq(:amendment)
      expect([cor.number.class, cor.year.class])
        .to eq([amd.number.class, amd.year.class])
      expect(cor).not_to respond_to(:supplement_number)
      expect(cor).not_to respond_to(:supplement_year)
    end

    # A year-less corrigendum parses and leaves `year` nil. The unnumbered
    # `+C:2016` form that CEN spells `AC` does not parse in BSI at all.
    it "leaves year nil for a year-less corrigendum" do
      cor = corrigendum_in("BS 1234:2015+C1")
      expect(cor.number).to eq("1")
      expect(cor.year).to be_nil
    end

    {
      "BS 1234:2015+C1:2016" => "urn:bsi:bs:1234:2015:cor:1:2016",
      "BS 1234:2015+C1" => "urn:bsi:bs:1234:2015:cor:1",
      "BS 1234:2015+C1:2016+A2:2018" =>
        "urn:bsi:bs:1234:2015:cor:1:2016:amd:2:2018",
      "NA+C1:2012 to BS EN 1090-2:2018" => "urn:bsi:bs:1090:-2:2018",
    }.each do |ref, urn|
      it "#{ref} renders, URNs and round-trips unchanged" do
        id = parse(ref)
        expect(id.to_s).to eq(ref)
        expect(id.to_urn).to eq(urn)
        expect(Pubid::Bsi::Identifier.from_hash(id.to_hash)).to eq(id)
      end
    end
  end

  # Pinned, not hidden. `mr_edition` (lib/pubid/identifier.rb) reads
  # `edition.number`, but BSI declares `edition` as a plain :string, so every
  # BSI identifier carrying an edition raises NoMethodError inside
  # `to_mr_string` — 40 of the 1501 pass fixtures. This is the same crash
  # CLAUDE.md records for BIPM, ASTM and IEEE, it is unchanged by this branch,
  # and it is the last MR-slug gap in the flavor. A fix turns this example red,
  # which is the signal to delete it.
  describe "a BSI edition still crashes the MR slug (pre-existing)" do
    it "raises NoMethodError because `edition` is a String, not a component" do
      expect { parse("BS HD IEC 60364-8-81 ED1").to_mr_string }
        .to raise_error(NoMethodError, /number/)
    end
  end
end
