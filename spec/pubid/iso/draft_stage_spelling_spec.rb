# frozen_string_literal: true

require "spec_helper"

# The ISO open-data feed spells draft-stage identifiers out ("DIS TR",
# "DIS ISP", ".../DIS Add 1") whereas pubid renders the merged canonical
# abbreviation ("DTR", "DISP", ".../DAD 1"). pubid 1.x accepted the expanded
# spelling; these specs lock in that the expanded forms parse again and
# normalise back to the canonical short form (the expanded spelling is an
# `abbr` alias, never `abbr.first`).
RSpec.describe "ISO draft-stage spelling aliases" do
  describe "expanded `<STAGE> <TYPE>` lead spelling normalises to the merged abbr" do
    {
      "ISO/IEC DIS ISP 15125-1"  => ["ISO/IEC DISP 15125-1", Pubid::Iso::Identifiers::InternationalStandardizedProfile],
      "ISO/IEC FDIS ISP 15125-1" => ["ISO/IEC FDISP 15125-1", Pubid::Iso::Identifiers::InternationalStandardizedProfile],
      "ISO/IEC DIS TR 14143-5"   => ["ISO/IEC DTR 14143-5", Pubid::Iso::Identifiers::TechnicalReport],
      "ISO/IEC FDIS TR 14143-5"  => ["ISO/IEC FDTR 14143-5", Pubid::Iso::Identifiers::TechnicalReport],
    }.each do |input, (canonical, klass)|
      context input do
        let(:parsed) { Pubid::Iso.parse(input) }

        it "parses to #{klass.name.split('::').last}" do
          expect(parsed).to be_a(klass)
        end

        it "renders the canonical short form #{canonical.inspect}" do
          expect(parsed.to_s).to eq(canonical)
        end
      end
    end
  end

  describe "expanded draft stage on a supplement normalises to the merged abbr" do
    {
      "ISO 9040:1990/DIS Add 1"             => ["ISO 9040:1990/DAD 1", Pubid::Iso::Identifiers::Addendum],
      "ISO 9040:1990/FDIS Add 1"            => ["ISO 9040:1990/FDAD 1", Pubid::Iso::Identifiers::Addendum],
      "ISO 10360-1:2000/DIS Cor 1"          => ["ISO 10360-1:2000/DCOR 1", Pubid::Iso::Identifiers::Corrigendum],
      "ISO 10360-1:2000/FDIS Cor 1"         => ["ISO 10360-1:2000/FDCOR 1", Pubid::Iso::Identifiers::Corrigendum],
      "ISO/IEC Guide 98:1993/DIS Suppl 1.2" => ["ISO/IEC Guide 98:1993/DSuppl 1.2", Pubid::Iso::Identifiers::Supplement],
    }.each do |input, (canonical, klass)|
      context input do
        let(:parsed) { Pubid::Iso.parse(input) }

        it "parses to #{klass.name.split('::').last}" do
          expect(parsed).to be_a(klass)
        end

        it "renders the canonical short form #{canonical.inspect}" do
          expect(parsed.to_s).to eq(canonical)
        end
      end
    end
  end

  describe "PWI supplement stage" do
    let(:parsed) { Pubid::Iso.parse("ISO/IEC Guide 98-3:2008/PWI Suppl 3") }

    it "parses to a Supplement" do
      expect(parsed).to be_a(Pubid::Iso::Identifiers::Supplement)
    end

    it "carries the :pwisuppl typed stage" do
      expect(parsed.typed_stage.code).to eq("pwisuppl")
    end

    it "round-trips its rendering" do
      expect(parsed.to_s).to eq("ISO/IEC Guide 98-3:2008/PWI Suppl 3")
    end
  end

  describe "numberless draft supplement" do
    let(:parsed) { Pubid::Iso.parse("ISO/IEC 9579/WD Amd") }

    it "parses to an Amendment" do
      expect(parsed).to be_a(Pubid::Iso::Identifiers::Amendment)
    end

    it "renders without a supplement number" do
      expect(parsed.to_s).to eq("ISO/IEC 9579/WD Amd")
    end
  end

  describe "from_hash round-trips the parsed identifier" do
    # The index serialises via to_hash and reads back via from_hash, so the
    # reconstructed identifier must render identically. (Inputs here all use
    # the canonical short abbr on render; the nested-supplement short/long
    # abbr quirk, e.g. DCOR vs DCor, is exercised elsewhere.)
    [
      "ISO/IEC DIS ISP 15125-1",
      "ISO/IEC DIS TR 14143-5",
      "ISO 9040:1990/DIS Add 1",
      "ISO/IEC Guide 98-3:2008/PWI Suppl 3",
      "ISO/IEC 9579/WD Amd",
    ].each do |input|
      it "round-trips #{input}" do
        parsed = Pubid::Iso.parse(input)
        reconstructed = Pubid::Iso::Identifier.from_hash(parsed.to_hash)
        expect(reconstructed.to_s).to eq(parsed.to_s)
      end
    end
  end
end
