require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::SpecialPublication do
  subject { described_class }

  describe ".parse" do
    context "basic SP identifiers" do
      describe "NIST SP 800-53" do
        subject { "NIST SP 800-53" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("SP")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("800-53")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST SP 250-1039" do
        subject { "NIST SP 250-1039" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "SP with revision" do
      describe "NIST SP 800-53r4" do
        subject { "NIST SP 800-53r4" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("4")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST SP 800-90r" do
        subject { "NIST SP 800-90r" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes bare revision to r1" do
          expect(parsed.to_s).to eq("NIST SP 800-90r1")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
        end
      end

      describe "NIST SP 800-57pt1r4" do
        subject { "NIST SP 800-57pt1r4" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part and revision" do
          expect(parsed.number.part).to eq("1")
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("4")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST SP 800-56Ar2" do
        subject { "NIST SP 800-56Ar2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix and revision" do
          expect(parsed.number.value).to eq("800-56A")
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST SP 260-126 rev 2013" do
        subject { "NIST SP 260-126 rev 2013" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to r2013 format" do
          expect(parsed.to_s).to eq("NIST SP 260-126r2013")
        end

        it "parses revision year as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("2013")
        end
      end
    end

    context "SP with edition year" do
      describe "NIST SP 330-2019" do
        subject { "NIST SP 330-2019" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e2019 format" do
          expect(parsed.to_s).to eq("NIST SP 330e2019")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2019")
        end
      end

      describe "NIST SP 304a-2017" do
        subject { "NIST SP 304a-2017" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e2017 format with uppercase letter" do
          expect(parsed.to_s).to eq("NIST SP 304Ae2017")
        end

        it "parses edition year with letter suffix" do
          expect(parsed.number.value).to eq("304A")
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2017")
        end
      end

      describe "NIST SP 260-162 2006ed." do
        subject { "NIST SP 260-162 2006ed." }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e2006 format" do
          expect(parsed.to_s).to eq("NIST SP 260-162e2006")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2006")
        end
      end
    end

    context "SP with update" do
      describe "NIST SP 800-53r4/Upd3-2015" do
        subject { "NIST SP 800-53r4/Upd3-2015" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision and update" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("4")
          expect(parsed.update.number).to eq("3")
          expect(parsed.update.year).to eq("2015")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST SP 500-300-upd" do
        subject { "NIST SP 500-300-upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST SP 500-300/Upd1-202105")
        end

        it "parses update" do
          expect(parsed.update.number).to eq("1")
          expect(parsed.update.year).to eq("2021")
          expect(parsed.update.month).to eq("05")
        end
      end
    end

    context "SP with version" do
      describe "NIST SP 500-268v1.1" do
        subject { "NIST SP 500-268v1.1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to ver notation" do
          expect(parsed.to_s).to eq("NIST SP 500-268ver1.1")
        end

        it "parses version" do
          expect(parsed.version).to eq("1.1")
        end
      end

      describe "NIST SP 800-60 Ver. 2.0" do
        subject { "NIST SP 800-60 Ver. 2.0" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to ver2.0" do
          expect(parsed.to_s).to eq("NIST SP 800-60ver2.0")
        end

        it "parses version" do
          expect(parsed.version).to eq("2.0")
        end
      end
    end

    context "SP with stage" do
      describe "NIST SP(IPD) 800-53r5" do
        subject { "NIST SP(IPD) 800-53r5" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to ipd stage" do
          expect(parsed.to_s).to eq("NIST SP 800-53r5 ipd")
        end

        it "parses revision and stage" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("5")
          expect(parsed.stage.to_s).to eq("ipd")
        end
      end

      describe "NIST SP(IPD) 800-53e5" do
        subject { "NIST SP(IPD) 800-53e5" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to ipd stage" do
          expect(parsed.to_s).to eq("NIST SP 800-53e5 ipd")
        end

        it "parses edition and stage" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("5")
          expect(parsed.stage.to_s).to eq("ipd")
        end
      end
    end

    context "SP with language" do
      describe "NIST SP 1262es" do
        subject { "NIST SP 1262es" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as SpecialPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST SP 1262 spa")
        end

        it "parses language" do
          expect(parsed.translation.language).to eq("spa")
        end
      end
    end
  end
end