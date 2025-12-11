require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Ieee::Identifiers::Base do
  describe ".parse" do
    context "basic IEEE identifiers" do
      it "parses IEEE Std identifiers" do
        id = PubidNew::Ieee.parse("IEEE Std 623-1976")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::Base)
        expect(id.to_s).to eq("IEEE Std 623-1976")
      end

      it "parses IEEE Std with letter prefix codes" do
        id = PubidNew::Ieee.parse("IEEE Std C37.111-2013")
        expect(id.to_s).to eq("IEEE Std C37.111-2013")
      end

      it "parses IEEE P (project) identifiers" do
        id = PubidNew::Ieee.parse("IEEE P11073-10404-10419")
        expect(id.to_s).to eq("IEEE P11073-10404-10419")
      end

      it "parses AIEE identifiers" do
        id = PubidNew::Ieee.parse("AIEE No 14-1925")
        expect(id.to_s).to eq("AIEE No 14-1925")
      end
    end

    context "IEC identifiers" do
      it "parses basic IEC identifiers" do
        id = PubidNew::Ieee.parse("IEC 61523-4")
        expect(id.to_s).to eq("IEC 61523-4")
      end

      it "parses IEC with edition format" do
        id = PubidNew::Ieee.parse("IEC 61671-2 Edition 1.0 2016-04")
        expect(id.to_s).to eq("IEC 61671-2 Edition 1.0 2016-04")
      end
    end

    context "parenthetical content" do
      it "preserves multi-part adoptions with commas" do
        id = PubidNew::Ieee.parse("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)")
        expect(id.to_s).to eq("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)")
      end

      it "preserves descriptive parenthetical notes" do
        id = PubidNew::Ieee.parse("AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)")
        expect(id).to be_a(PubidNew::Ieee::Identifiers::Base)
        expect(id.to_s).to eq("AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)")
      end
    end

    context "relationships" do
      let(:related_id) do
        PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "802.11",
          year: "2012"
        )
      end

      it "renders single relationship with one identifier" do
        relationship = PubidNew::Ieee::Components::Relationship.new(
          relationship_type: PubidNew::Ieee::Components::Relationship::REVISION_OF,
          related_identifiers: [related_id]
        )

        id = PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "802.11",
          year: "2016",
          relationships: [relationship]
        )

        expect(id.to_s).to eq("IEEE Std 802.11-2016 (Revision of IEEE Std 802.11-2012)")
      end

      it "renders multiple relationships separated by /" do
        rev_rel = PubidNew::Ieee::Components::Relationship.new(
          relationship_type: PubidNew::Ieee::Components::Relationship::REVISION_OF,
          related_identifiers: [related_id]
        )

        inc_rel = PubidNew::Ieee::Components::Relationship.new(
          relationship_type: PubidNew::Ieee::Components::Relationship::INCORPORATES,
          related_identifiers: [PubidNew::Ieee::Identifiers::Base.new(
            publisher: "IEEE",
            type: "Std",
            code: "802.11a",
            year: "1999"
          )]
        )

        id = PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "802.11",
          year: "2016",
          relationships: [rev_rel, inc_rel]
        )

        expect(id.to_s).to eq("IEEE Std 802.11-2016 (Revision of IEEE Std 802.11-2012 / incorporates IEEE Std 802.11a-1999)")
      end

      it "renders relationship with multiple identifiers" do
        id1 = PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "1232",
          year: "1995"
        )

        id2 = PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "1232.1",
          year: "1997"
        )

        relationship = PubidNew::Ieee::Components::Relationship.new(
          relationship_type: PubidNew::Ieee::Components::Relationship::REVISION_OF,
          related_identifiers: [id1, id2]
        )

        id = PubidNew::Ieee::Identifiers::Base.new(
          publisher: "IEEE",
          type: "Std",
          code: "1232",
          year: "2002",
          relationships: [relationship]
        )

        expect(id.to_s).to eq("IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995 and IEEE Std 1232.1-1997)")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        test_cases = [
          "IEEE Std 623-1976",
          "IEEE Std C37.111-2013",
          "IEEE P11073-10404-10419",
          "IEC 61523-4",
          "AIEE No 14-1925",
          "IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)",
          "AIEE No 19-1943 (Supercedes A. I. E. E. Standard No. 19-1938)"
        ]

        test_cases.each do |test_case|
          expect(PubidNew::Ieee.parse(test_case).to_s).to eq(test_case)
        end
      end
    end
  end
end