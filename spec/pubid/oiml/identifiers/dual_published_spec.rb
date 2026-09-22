# frozen_string_literal: true

require "spec_helper"

# OIML sometimes co-publishes a document with another SDO (ISO confirmed so
# far), printed as two full identifiers joined by "|": each side names the
# same document in its own SDO's scheme (pubid issue #437).
RSpec.describe Pubid::Oiml::Identifiers::DualPublished do
  describe ".parse" do
    context "OIML side printed second" do
      subject(:id) { Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024") }

      it { is_expected.to be_a(described_class) }

      it "parses the first side as the external (ISO) identifier" do
        expect(id.first).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.first.to_s).to eq("ISO 4064-1:2024")
      end

      it "parses the second side as the OIML identifier" do
        expect(id.second).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(id.second.to_s).to eq("OIML R 49-1:2024")
      end

      it "identifies the OIML and external sides regardless of naming" do
        expect(id.oiml_identifier).to eq(id.second)
        expect(id.external_identifier).to eq(id.first)
      end

      it "round-trips to_s back to the original string" do
        expect(id.to_s).to eq("ISO 4064-1:2024|OIML R 49-1:2024")
      end
    end

    context "OIML side printed first" do
      subject(:id) { Pubid::Oiml.parse("OIML R 49-1:2024|ISO 4064-1:2024") }

      it "identifies the OIML and external sides regardless of order" do
        expect(id.oiml_identifier).to eq(id.first)
        expect(id.external_identifier).to eq(id.second)
      end

      it "round-trips to_s back to the original string" do
        expect(id.to_s).to eq("OIML R 49-1:2024|ISO 4064-1:2024")
      end
    end

    context "malformed dual-published strings" do
      it "raises Parslet::ParseFailed when neither side is OIML" do
        expect { Pubid::Oiml.parse("ISO 4064-1:2024|ISO 4064-2:2024") }
          .to raise_error(Parslet::ParseFailed)
      end

      it "raises Parslet::ParseFailed when both sides are OIML" do
        expect { Pubid::Oiml.parse("OIML R 49-1:2024|OIML R 49-2:2024") }
          .to raise_error(Parslet::ParseFailed)
      end

      it "raises Parslet::ParseFailed for a three-part pipe string" do
        expect do
          Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024|IEC 60050")
        end.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "identity delegation to the OIML side" do
    subject(:id) { Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024") }

    it "delegates #root to the OIML identifier" do
      expect(id.root).to eq(id.second)
      expect(id.root.number).to eq("49")
    end

    it "delegates #code to the OIML identifier" do
      expect(id.code.number).to eq("49")
      expect(id.code.part).to eq("1")
    end

    it "delegates #type/#publisher to the OIML identifier" do
      expect(id.type).to eq("R")
      expect(id.publisher).to eq("OIML")
    end
  end

  describe "#to_hash / .from_hash" do
    subject(:id) { Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024") }

    it "serializes both sides with their own polymorphic _type" do
      expect(id.to_hash).to eq(
        "_type" => "pubid:oiml:dual-published",
        "first" => {
          "_type" => "pubid:iso:international-standard",
          "number" => "4064",
          "part" => "1",
          "year" => "2024",
        },
        "second" => {
          "_type" => "pubid:oiml:recommendation",
          "publisher" => "OIML",
          "year" => "2024",
          "number" => "49",
          "part" => "1",
        },
      )
    end

    it "round-trips through from_hash to an equal object" do
      restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
      expect(restored).to eq(id)
      expect(restored.to_s).to eq(id.to_s)
    end

    it "reconstructs the concrete subclass from _type" do
      restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
      expect(restored).to be_a(described_class)
      expect(restored.first).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      expect(restored.second).to be_a(Pubid::Oiml::Identifiers::Recommendation)
    end
  end

  describe "#to_urn" do
    it "generates a URN for the OIML side only" do
      id = Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024")
      expect(id.to_urn).to eq("urn:oiml:r:49-1:2024")
    end
  end

  describe "annotated rendering" do
    it "does not raise when annotated: true is requested" do
      id = Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024")
      expect { id.to_s(annotated: true) }.not_to raise_error
    end
  end

  describe "#exclude / #matches?" do
    it "matches another dual-published id when the year is excluded" do
      with_year = Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024")
      without_year = Pubid::Oiml.parse("ISO 4064-1|OIML R 49-1")
      expect(with_year.matches?(without_year, ignore: [:year])).to be true
    end
  end

  # Documented, deliberately out of scope for pubid #437 (see
  # docs/flavors/oiml.md) — pinned so a future change to either shows up
  # here, not silently.
  describe "known gaps" do
    # `edition` is not delegated to the OIML side. OIML models edition as a
    # plain String, but the shared #mr_edition/#urn_edition assume
    # Components::Edition and call `edition.number` — a PRE-EXISTING crash in
    # OIML itself, with no DualPublished involved (confirmed on main).
    # Delegating here would only reproduce that crash through a second path,
    # so the MR slug/URN silently omit the edition instead.
    it "does not include the OIML side's edition in the MR slug" do
      id = Pubid::Oiml.parse("ISO 4064-1:2024|OIML E 5 6th Edition 2015 (E)")
      expect(id.second.edition).to eq("6th")
      expect { id.to_mr_string }.not_to raise_error
      expect(id.to_mr_string).not_to include("6th")
    end

    # Matches, not regresses, the existing shipped behavior of the closest
    # precedent (IEEE's AdoptedStandard): Renderers::Annotator only recurses
    # into base/ids/identifiers/bundled_with, none of which this class (or
    # AdoptedStandard) uses, so a nested side's own number/year tokens are
    # never found. Only the top-level delegated publisher/type happen to
    # match, via the same top-level-attribute mechanism every other
    # annotated identifier uses.
    it "annotates only the OIML side's publisher/type" do
      id = Pubid::Oiml.parse("ISO 4064-1:2024|OIML R 49-1:2024")
      annotated = id.to_s(annotated: true)

      expect(annotated).to include('<span class="publisher">OIML</span>')
      expect(annotated).to include('<span class="doctype">R</span>')
      expect(annotated).not_to include('<span class="publisher">ISO</span>')
      expect(annotated).not_to include("49-1</span>")
    end
  end
end
