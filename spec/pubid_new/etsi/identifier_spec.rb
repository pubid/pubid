require "spec_helper"

RSpec.describe PubidNew::Etsi do
  describe ".parse" do
    context "basic ETSI identifiers" do
      it "parses ETSI EN 300 058-3 V1.2.4 (1998-06)" do
        result = described_class.parse("ETSI EN 300 058-3 V1.2.4 (1998-06)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI EN 300 058-3 V1.2.4 (1998-06)")
      end

      it "parses ETSI ETR 298 ed.1 (1996-09) with edition" do
        result = described_class.parse("ETSI ETR 298 ed.1 (1996-09)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI ETR 298 ed.1 (1996-09)")
      end

      it "parses ETSI GS ZSM 012 V1.1.1 (2022-12)" do
        result = described_class.parse("ETSI GS ZSM 012 V1.1.1 (2022-12)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GS ZSM 012 V1.1.1 (2022-12)")
      end

      it "parses ETSI GTS 02.01 V5.5.0 (1999-08)" do
        result = described_class.parse("ETSI GTS 02.01 V5.5.0 (1999-08)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GTS 02.01 V5.5.0 (1999-08)")
      end

      it "parses ETSI GTS 02.06-DCS V3.0.0 (1995-01) with part" do
        result = described_class.parse("ETSI GTS 02.06-DCS V3.0.0 (1995-01)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GTS 02.06-DCS V3.0.0 (1995-01)")
      end

      it "parses ETSI GR NFV-EVE 022 V5.1.1 (2022-12) with hyphen in series" do
        result = described_class.parse("ETSI GR NFV-EVE 022 V5.1.1 (2022-12)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GR NFV-EVE 022 V5.1.1 (2022-12)")
      end

      it "parses ETSI GR mWT 028 V1.1.1 (2023-04)" do
        result = described_class.parse("ETSI GR mWT 028 V1.1.1 (2023-04)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GR mWT 028 V1.1.1 (2023-04)")
      end

      it "parses ETSI GS ECI 001-5-2 V1.1.1 (2017-07) with part and subpart" do
        result = described_class.parse("ETSI GS ECI 001-5-2 V1.1.1 (2017-07)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI GS ECI 001-5-2 V1.1.1 (2017-07)")
      end
    end

    context "ETSI identifiers with corrigenda" do
      it "parses ETSI ETR 310/C1 ed.1 (1996-10)" do
        result = described_class.parse("ETSI ETR 310/C1 ed.1 (1996-10)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Corrigendum)
        expect(result.number).to eq(1)
        expect(result.base).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI ETR 310/C1 ed.1 (1996-10)")
      end
    end

    context "ETSI identifiers with amendments" do
      it "parses ETSI ETS 300 097-1/A1 ed.1 (1994-11)" do
        result = described_class.parse("ETSI ETS 300 097-1/A1 ed.1 (1994-11)")

        expect(result).to be_a(PubidNew::Etsi::Identifiers::Amendment)
        expect(result.number).to eq(1)
        expect(result.base).to be_a(PubidNew::Etsi::Identifiers::Base)
        expect(result.to_s).to eq("ETSI ETS 300 097-1/A1 ed.1 (1994-11)")
      end
    end

    context "round-trip fidelity" do
      [
        "ETSI EN 300 058-3 V1.2.4 (1998-06)",
        "ETSI ETR 298 ed.1 (1996-09)",
        "ETSI GS ZSM 012 V1.1.1 (2022-12)",
        "ETSI GTS 02.01 V5.5.0 (1999-08)",
        "ETSI GTS 02.06-DCS V3.0.0 (1995-01)",
        "ETSI GR NFV-EVE 022 V5.1.1 (2022-12)",
        "ETSI GR mWT 028 V1.1.1 (2023-04)",
        "ETSI GS ECI 001-5-2 V1.1.1 (2017-07)",
        "ETSI ETR 310/C1 ed.1 (1996-10)",
        "ETSI ETS 300 097-1/A1 ed.1 (1994-11)",
      ].each do |identifier|
        it "round-trips #{identifier}" do
          result = described_class.parse(identifier)
          expect(result.to_s).to eq(identifier)
        end
      end
    end
  end
end
