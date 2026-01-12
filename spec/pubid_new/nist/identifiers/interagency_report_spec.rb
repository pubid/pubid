require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::InteragencyReport do
  subject { described_class }

  describe ".parse" do
    context "basic IR identifiers" do
      describe "NBS IR 73-212" do
        subject { "NBS IR 73-212" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("IR")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("73-212")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST IR 84-2946" do
        subject { "NIST IR 84-2946" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("84-2946")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS IR 80-2073.3" do
        subject { "NBS IR 80-2073.3" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses decimal number" do
          expect(parsed.number.value).to eq("80-2073.3")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NISTIR 8115" do
        subject { "NISTIR 8115" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to NIST IR" do
          expect(parsed.to_s).to eq("NIST IR 8115")
        end
      end

      describe "NBS.IR.73-212" do
        subject { "NBS.IR.73-212" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NBS IR 73-212")
        end
      end
    end

    context "IR with revision" do
      describe "NBS IR 73-197r" do
        subject { "NBS IR 73-197r" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes revision to r1" do
          expect(parsed.to_s).to eq("NBS IR 73-197r1")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
        end
      end

      describe "NIST IR 6945r" do
        subject { "NIST IR 6945r" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes revision to r1" do
          expect(parsed.to_s).to eq("NIST IR 6945r1")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
        end
      end
    end

    context "IR with update" do
      describe "NISTIR 8115r1/upd" do
        subject { "NISTIR 8115r1/upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 8115r1/Upd1-202103")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
        end

        it "parses update" do
          expect(parsed.update.number).to eq("1")
          expect(parsed.update.year).to eq("2021")
          expect(parsed.update.month).to eq("03")
        end
      end

      describe "NISTIR 8170-upd" do
        subject { "NISTIR 8170-upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 8170/Upd1-202003")
        end

        it "parses update" do
          expect(parsed.update.number).to eq("1")
        end
      end

      describe "NIST IR 4743rJun1992" do
        subject { "NIST IR 4743rJun1992" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 4743/Upd1-199206")
        end

        it "parses update from revision date" do
          expect(parsed.update.number).to eq("1")
          expect(parsed.update.year).to eq("1992")
          expect(parsed.update.month).to eq("06")
        end
      end

      describe "NIST IR 4335rNov1990" do
        subject { "NIST IR 4335rNov1990" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 4335/Upd1-199011")
        end

        it "parses update from revision date" do
          expect(parsed.update.year).to eq("1990")
          expect(parsed.update.month).to eq("11")
        end
      end

      describe "NIST IR 4335r11/90" do
        subject { "NIST IR 4335r11/90" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 4335/Upd1-199011")
        end

        it "parses update from revision date parts" do
          expect(parsed.update.month).to eq("11")
          expect(parsed.update.year).to eq("1990")
        end
      end

      describe "NIST.IR.8170-upd" do
        subject { "NIST.IR.8170-upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 8170/Upd1-202003")
        end
      end

      describe "NISTIR 8211-upd" do
        subject { "NISTIR 8211-upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST IR 8211/Upd1-2021")
        end
      end
    end

    context "IR with language" do
      describe "NIST IR 8115chi" do
        subject { "NIST IR 8115chi" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST IR 8115 zho")
        end

        it "parses language" do
          expect(parsed.translation.language).to eq("zho")
        end
      end

      describe "NIST IR 8118r1es" do
        subject { "NIST IR 8118r1es" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST IR 8118r1 spa")
        end

        it "parses revision and language" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1")
          expect(parsed.translation.language).to eq("spa")
        end
      end

      describe "NIST.IR.8115viet" do
        subject { "NIST.IR.8115viet" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST IR 8115 vie")
        end

        it "parses language" do
          expect(parsed.translation.language).to eq("vie")
        end
      end

      describe "NIST.IR.8178port" do
        subject { "NIST.IR.8178port" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST IR 8178 por")
        end

        it "parses language" do
          expect(parsed.translation.language).to eq("por")
        end
      end

      describe "NIST IR 8115(esp)" do
        subject { "NIST IR 8115(esp)" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language format" do
          expect(parsed.to_s).to eq("NIST IR 8115 esp")
        end

        it "parses language" do
          expect(parsed.translation.language).to eq("esp")
        end
      end

      describe "NISTIR 8259Aes" do
        subject { "NISTIR 8259Aes" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes language code" do
          expect(parsed.to_s).to eq("NIST IR 8259A spa")
        end

        it "parses letter suffix and language" do
          expect(parsed.number.value).to eq("8259A")
          expect(parsed.translation.language).to eq("spa")
        end
      end
    end

    context "IR with letter suffix" do
      describe "NIST IR 6529-a" do
        subject { "NIST IR 6529-a" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes suffix to uppercase" do
          expect(parsed.to_s).to eq("NIST IR 6529-A")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("6529-A")
        end
      end

      describe "NIST IR 5443-A" do
        subject { "NIST IR 5443-A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("5443-A")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST IR 7297-B" do
        subject { "NIST IR 7297-B" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("7297-B")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST IR 6099a" do
        subject { "NIST IR 6099a" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes suffix to uppercase" do
          expect(parsed.to_s).to eq("NIST IR 6099A")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("6099A")
        end
      end

      describe "NIST IR 7103b" do
        subject { "NIST IR 7103b" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes suffix to uppercase" do
          expect(parsed.to_s).to eq("NIST IR 7103B")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("7103B")
        end
      end

      describe "NIST IR 7356-CAS" do
        subject { "NIST IR 7356-CAS" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses multi-letter suffix" do
          expect(parsed.number.value).to eq("7356-CAS")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "IR with edition year" do
      describe "NIST IR 5672-2018" do
        subject { "NIST IR 5672-2018" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to edition format" do
          expect(parsed.to_s).to eq("NIST IR 5672e2018")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2018")
        end
      end

      describe "NIST IR 6969-2018" do
        subject { "NIST IR 6969-2018" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to edition format" do
          expect(parsed.to_s).to eq("NIST IR 6969e2018")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2018")
        end
      end

      describe "NIST IR 8200-2018" do
        subject { "NIST IR 8200-2018" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to edition format" do
          expect(parsed.to_s).to eq("NIST IR 8200e2018")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2018")
        end
      end
    end

    context "IR with parts" do
      describe "NBS IR 73-285p1" do
        subject { "NBS IR 73-285p1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes part notation" do
          expect(parsed.to_s).to eq("NBS IR 73-285pt1")
        end

        it "parses part" do
          expect(parsed.number.part).to eq("1")
        end
      end

      describe "NBS IR 79-1591-1" do
        subject { "NBS IR 79-1591-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to part notation" do
          expect(parsed.to_s).to eq("NBS IR 79-1591pt1")
        end

        it "parses part from trailing number" do
          expect(parsed.number.part).to eq("1")
        end
      end

      describe "NBS IR 80-2111-1" do
        subject { "NBS IR 80-2111-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to part notation" do
          expect(parsed.to_s).to eq("NBS IR 80-2111pt1")
        end
      end

      describe "NBS IR 80-2111-11" do
        subject { "NBS IR 80-2111-11" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to part notation" do
          expect(parsed.to_s).to eq("NBS IR 80-2111pt11")
        end

        it "parses multi-digit part" do
          expect(parsed.number.part).to eq("11")
        end
      end

      describe "NBS IR 84-2857-1" do
        subject { "NBS IR 84-2857-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to part notation" do
          expect(parsed.to_s).to eq("NBS IR 84-2857pt1")
        end
      end

      describe "NBS IR 74-577-1" do
        subject { "NBS IR 74-577-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as InteragencyReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to volume notation" do
          expect(parsed.to_s).to eq("NBS IR 74-577v1")
        end

        it "parses as volume" do
          expect(parsed.volume).to eq("1")
        end
      end
    end
  end
end
