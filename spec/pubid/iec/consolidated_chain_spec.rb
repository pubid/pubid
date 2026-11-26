# frozen_string_literal: true

require "spec_helper"

# The IEC consolidated-form face (pubid#788): the `+AMD+COR` composition
# chains the IEC catalogue emits. The attestation base is relaton-data-iec —
# 2,031 records carry a consolidated primary docidentifier
# (`IEC <n>[-p[-sp]]:<y>+AMD<m>:<y>[+AMD…][ CSV[/COR<m>:<y>]]`; the CSV face
# is the consolidated edition, the OBP PDFs are named `{ed1.1}`), and the
# published `urn:iec:std:` values pin the official URN byte-for-byte. The
# bare chain (no CSV) is the composition face without the deliverable —
# IEC's own citation style in the records' abstracts ("IEC 62148-12+AMD1:
# 2022 couvre…") and first-class in the model since pubid v1.
# One real row per attested shape family (relaton-data-iec harvest, 43
# distinct plus-shapes; a representative of each family, with its PUBLISHED
# official URN — these strings are copied from the data records, not
# invented).
ATTESTED_ROWS = [
  ["IEC 60034-18-41:2014+AMD1:2019 CSV",
   "urn:iec:std:iec:60034-18-41:2014::csv::plus:amd:1:2019"],
  ["IEC 60038:2009+AMD1:2021 CSV",
   "urn:iec:std:iec:60038:2009::csv::plus:amd:1:2021"],
  ["IEC 60068-2-6:1982+AMD1:1983+AMD2:1985 CSV",
   "urn:iec:std:iec:60068-2-6:1982::csv::plus:amd:1:1983:plus:amd:2:1985"],
  ["IEC 60034-1:1969+AMD1:1977+AMD2:1979+AMD3:1980 CSV",
   "urn:iec:std:iec:60034-1:1969::csv::plus:amd:1:1977:plus:amd:2:1979:" \
   "plus:amd:3:1980"],
  ["IEC 60335-1:2010+AMD1:2013 CSV/COR1:2014",
   "urn:iec:std:iec:60335-1:2010::csv::plus:amd:1:2013::cor:1:2014"],
  ["IEC 60287-1-1:1994+AMD1:1995+AMD2:2001 CSV/COR1:2006",
   "urn:iec:std:iec:60287-1-1:1994::csv::plus:amd:1:1995:plus:amd:2:2001" \
   "::cor:1:2006"],
  ["CISPR 11:1975+AMD1:1976 CSV",
   "urn:iec:std:cispr:11:1975::csv::plus:amd:1:1976"],
  ["CISPR 16-1-1:2006+AMD1:2006+AMD2:2007 CSV",
   "urn:iec:std:cispr:16-1-1:2006::csv::plus:amd:1:2006:plus:amd:2:2007"],
  ["IEC TR 60721-4-1:2001+AMD1:2003 CSV",
   "urn:iec:std:iec:60721-4-1:2001:tr:csv::plus:amd:1:2003"],
  ["IEC TS 60479-1:2005+AMD1:2016 CSV",
   "urn:iec:std:iec:60479-1:2005:ts:csv::plus:amd:1:2016"],
  ["ISO/IEC 11801-1:2017+AMD1:2025 CSV",
   "urn:iec:std:iso-iec:11801-1:2017::csv::plus:amd:1:2025"],
  ["IEC/IEEE 62209-1528:2020+AMD1:2026 CSV",
   "urn:iec:std:iec-ieee:62209-1528:2020::csv::plus:amd:1:2026"],
  ["IEC/ASTM 62885-7:2020+AMD1:2022 CSV",
   "urn:iec:std:iec-astm:62885-7:2020::csv::plus:amd:1:2022"],
  ["ISO/IEC TR 29106:2007+AMD1:2012+AMD2:2019 CSV",
   "urn:iec:std:iso-iec:29106:2007:tr:csv::plus:amd:1:2012:plus:amd:2:2019"],
].freeze

RSpec.describe "IEC consolidated chains (+AMD+COR)" do
  let(:iec) { (Pubid.eager_load_flavors!; Pubid::Registry.get("iec")) }

  describe "the attested catalogue rows" do
    ATTESTED_ROWS.each do |(input, urn)|
      describe input do
        it "parses" do
          expect { iec.parse(input) }.not_to raise_error
        end

        it "renders byte-exact" do
          expect(iec.parse(input).to_s).to eq(input)
        end

        it "re-parses its own render" do
          expect(iec.parse(iec.parse(input).to_s)).to eq(iec.parse(input))
        end

        it "round-trips through from_hash" do
          id = iec.parse(input)
          expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
        end

        it "emits the published official URN byte-for-byte" do
          expect(iec.parse(input).to_urn).to eq(urn)
        end

        it "round-trips through the pubid-scheme URN" do
          id = iec.parse(input)
          expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
        end
      end
    end
  end

  describe "the typed composition" do
    it "composes typed amendment and corrigendum objects onto the base" do
      id = iec.parse("IEC 60601-1:2005+AMD1:2012+COR1:2012")

      expect(id).to be_a(Pubid::Iec::Identifiers::ConsolidatedIdentifier)
      expect(id.identifiers.map(&:class))
        .to eq([Pubid::Iec::Identifiers::InternationalStandard,
                Pubid::Iec::Identifiers::Amendment,
                Pubid::Iec::Identifiers::Corrigendum])
      expect(id.identifiers.first.to_s).to eq("IEC 60601-1:2005")
      expect(id.supplements.map do |s|
        [s.type.type_code, s.number.to_s, s.year.to_s]
      end).to eq([%w[amd 1 2012], %w[cor 1 2012]])
    end

    it "builds the same identifier by hand as by parse" do
      std = Pubid::Iec::Identifiers::InternationalStandard.new(
        number: "60601", part: "1", year: 2005,
      )
      amd = Pubid::Iec::Identifiers::Amendment.new(number: "1", year: 2012)
      cor = Pubid::Iec::Identifiers::Corrigendum.new(number: "1", year: 2012)
      built = Pubid::Iec::Identifiers::ConsolidatedIdentifier.new(
        identifiers: [std, amd, cor],
      )

      expect(built.to_s).to eq("IEC 60601-1:2005+AMD1:2012+COR1:2012")
      expect(built).to eq(iec.parse("IEC 60601-1:2005+AMD1:2012+COR1:2012"))
    end

    it "parses the chain members' own years and ordinals" do
      id = iec.parse("IEC 60068-2-6:1982+AMD1:1983+AMD2:1985 CSV")
      chain = id.base.identifiers

      expect(chain[1].number.to_s).to eq("1")
      expect(chain[1].year.to_s).to eq("1983")
      expect(chain[2].number.to_s).to eq("2")
      expect(chain[2].year.to_s).to eq("1985")
    end
  end

  describe "the structural algebra (drop_supplements)" do
    let(:base) { iec.parse("IEC 60601-1:2005") }
    let(:cons) { iec.parse("IEC 60601-1:2005+AMD1:2012+COR1:2012") }

    it "drops the composition to the base standard alone" do
      expect(cons.drop_supplements.to_s).to eq("IEC 60601-1:2005")
      expect(cons.drop_supplements).to eq(base)
    end

    it "peels the chain on the structural exclusions" do
      expect(cons.exclude(:amendment)).to eq(base)
      expect(cons.exclude(:supplement)).to eq(base)
    end

    it "matches the base record under the structural ignores" do
      expect(base.matches?(cons, ignore: [:amendment])).to be true
      expect(base.matches?(cons, ignore: [:supplement])).to be true
      expect(cons.matches?(base, ignore: [:amendment])).to be true
    end

    it "keeps the chain distinct without the ignores" do
      expect(base.matches?(cons)).to be false
      expect(base).not_to eq(cons)
    end

    it "answers edition_of? between two consolidated states of one base" do
      later = iec.parse("IEC 60601-1:2005+AMD1:2015")
      expect(later.edition_of?(cons)).to be true
    end

    it "keeps a corrigendum-over-CSV peel at the wrapped document" do
      # the supplements keep themselves in base_document (the flavor-wide
      # shape — ISO's supplements do too); the VAP view is what peels, and
      # the peel reaches through the chain behind it
      csv_cor = iec.parse("IEC 60335-1:2010+AMD1:2013 CSV/COR1:2014")
      expect(csv_cor.base.base_document.to_s).to eq("IEC 60335-1:2010")
    end
  end

  describe "the MR string" do
    # The wrapper slugs were the flat base slug before: they dropped the
    # part (colliding across parts: 60601-1 CSV and 60601-2 CSV both keyed
    # `iec.60601.2005`), hid every chain member but the last suffix, and
    # shared one slug with the bare base document. The composition keeps
    # the full designation, marks each member `plus-`, and carries the VAP
    # code, so every distinct identifier keys a distinct slug.
    {
      "IEC 60601-1:2005" =>
        "iec.60601-1.2005",
      "IEC 60601-1:2005+AMD1:2012+COR1:2012" =>
        "iec.60601-1.2005_plus-amd.1.2012_plus-cor.1.2012",
      "IEC 60601-1:2005+AMD1:2012 CSV" =>
        "iec.60601-1.2005_plus-amd.1.2012_csv",
      "IEC 60601-1:2005+AMD1:2013 CSV/COR1:2014" =>
        "iec.60601-1.2005_plus-amd.1.2013_csv_cor.1.2014",
      "IEC 60038:2009 CSV" =>
        "iec.60038.2009_csv",
      "IEC 60034-1:1969+AMD1:1977+AMD2:1979 CSV" =>
        "iec.60034-1.1969_plus-amd.1.1977_plus-amd.2.1979_csv",
      # the standalone chain keeps its own, un-`plus`-ed slug
      "IEC 60601-1:2005/Amd 1:2012" =>
        "iec.60601-1.2005_amd.1.2012",
    }.each do |input, mr|
      it "keys #{input.inspect} as #{mr.inspect}" do
        expect(iec.parse(input).to_mr_string).to eq(mr)
      end
    end

    it "keeps distinct identifiers distinct" do
      # the part-drop collision: two DIFFERENT documents keyed one slug
      expect(iec.parse("IEC 60601-1:2005+AMD1:2012 CSV").to_mr_string)
        .not_to eq(iec.parse("IEC 60601-2:2005+AMD1:2012 CSV").to_mr_string)
      # the bare base and its consolidated edition never share a slug
      expect(iec.parse("IEC 60601-1:2005").to_mr_string)
        .not_to eq(iec.parse("IEC 60601-1:2005+AMD1:2012 CSV").to_mr_string)
      # the consolidated chain and the standalone chain never share one
      expect(iec.parse("IEC 60601-1:2005+AMD1:2012 CSV").to_mr_string)
        .not_to eq(iec.parse("IEC 60601-1:2005/AMD1:2012").to_mr_string)
    end
  end

  describe "the un-renderable trailing-edition chain" do
    # "IEC 60068:2005+AMD1:2012 ED2" parsed and then rendered the edition
    # onto the base designation ("IEC 60068:2005 ED2+AMD1:2012") — a face
    # no IEC source prints (0 of the 33,070 primary docidentifiers in
    # relaton-data-iec carry an edition facet on a chain; 0 rows in the gem
    # fixtures) and the grammar rejects, so parse(to_s) raised. The
    # consolidated edition IS the CSV face; where the printed edition
    # appears it rides the CSV face and round-trips.
    it "rejects the bare chain with a trailing edition" do
      expect { iec.parse("IEC 60068:2005+AMD1:2012 ED2") }
        .to raise_error(Pubid::Errors::ParseError, /trailing edition/)
    end

    it "rejects it on a longer chain too" do
      expect { iec.parse("IEC 60068:2005+AMD1:2012+COR1:2012 ED2") }
        .to raise_error(Pubid::Errors::ParseError, /trailing edition/)
    end

    it "sets input and flavor on the rejection" do
      Pubid::Iec::Identifier.parse("IEC 60068:2005+AMD1:2012 ED2")
    rescue Pubid::Errors::ParseError => e
      expect(e.input).to eq("IEC 60068:2005+AMD1:2012 ED2")
      expect(e.flavor).to eq("iec")
    end

    it "keeps the edition-bearing CSV face parsing" do
      id = iec.parse("IEC 60068:2005+AMD1:2012 CSV ED1")
      expect(id.to_s).to eq("IEC 60068:2005+AMD1:2012 CSV ED1")
      expect(iec.parse(id.to_s)).to eq(id)
    end

    it "keeps a member-edition-less chain parsing" do
      expect(iec.parse("IEC 60068:2005+AMD1:2012")).to be_a(
        Pubid::Iec::Identifiers::ConsolidatedIdentifier,
      )
    end

    it "still deserializes a stored member-edition chain (parse-only reject)" \
       do
      hash = {
        "_type" => "pubid:iec:consolidated-identifier",
        "identifiers" => [
          { "_type" => "pubid:iec:international-standard", "number" => "60068",
            "year" => "2005", "edition" => "2" },
          { "_type" => "pubid:iec:amendment", "number" => "1",
            "year" => "2012" },
        ],
      }
      expect(Pubid::Iec::Identifier.from_hash(hash).identifiers.first.edition)
        .to be_a(Pubid::Components::Edition)
    end
  end

  describe "the malformed chains" do
    # every attested chain supplement carries an ordinal and a year
    # ("+AMD1:2012"); the grammar admits no weaker face
    it "rejects +AMD without a number" do
      expect { iec.parse("IEC 60068:2005+AMD") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects +COR without a number" do
      expect { iec.parse("IEC 60068:2005+COR") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a dangling trailing plus" do
      expect { iec.parse("IEC 60068:2005+") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a truncated chain year" do
      expect { iec.parse("IEC 60068:2005+AMD1:20") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a dangling CSV/COR slash" do
      expect { iec.parse("IEC 60068:2005+AMD1:2012 CSV/") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a doubled CSV suffix" do
      expect { iec.parse("IEC 60068:2005+AMD1:2012 CSV CSV") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end
end
