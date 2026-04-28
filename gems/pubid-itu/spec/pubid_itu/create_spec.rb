module Pubid::Itu
  RSpec.describe Identifier do
    describe "creating new identifier" do
      subject do
        described_class.create(**{ number: number, sector: sector,
                                   series: series }.merge(params))
      end
      let(:number) { 123 }
      let(:sector) { "R" }
      let(:series) { "V" }
      let(:params) { {} }

      it "renders identifier" do
        expect(subject.to_s).to eq("ITU-R V.#{number}")
      end

      context "with part" do
        let(:params) { { part: 1 } }

        it "renders identifier with part and year" do
          expect(subject.to_s).to eq("ITU-R V.#{number}-1")
        end

        context "with subpart" do
          let(:params) { { part: "1-2" } }

          it "renders identifier with part and year" do
            expect(subject.to_s).to eq("ITU-R V.#{number}-1-2")
          end
        end
      end

      context "dual-numbered identifier" do
        let(:sector) { "T" }
        let(:params) do
          { series: "G", number: 780,
            second_number: { series: "Y", number: 1351 } }
        end

        it "renders dual-numbered identifier" do
          expect(subject.to_s).to eq("ITU-T G.780/Y.1351")
        end
      end

      context "supplement" do
        context "series supplement" do
          let(:sector) { "T" }
          let(:params) do
            { number: 1, type: :supplement,
              base: Identifier.create(sector: "T", series: "H") }
          end

          it "renders series supplement" do
            expect(subject.to_s).to eq("ITU-T H Suppl. 1")
          end
        end

        context "document's supplement" do
          let(:sector) { "T" }
          let(:params) do
            { number: 1, type: :supplement,
              base: Identifier.create(sector: "T", series: "H", number: 1) }
          end

          it "renders series supplement" do
            expect(subject.to_s).to eq("ITU-T H.1 Suppl. 1")
          end
        end
      end

      context "identifier with language" do
        let(:params) { { language: "en" } }

        it "renders identifier with language" do
          expect(subject.to_s).to eq("ITU-R V.123-E")
        end
      end

      context "Contributions" do
        let(:series) { "SG07" }
        let(:number) { 1000 }
        let(:params) { { type: :contribution } }

        it "renders contribution identifier" do
          expect(subject.to_s).to eq("SG07-C1000")
        end
      end

      context "Special Publication" do
        let(:sector) { "T" }
        let(:series) { "OB" }
        let(:params) { { date: { month: 0o1, year: 2024 } } }
        # let(:params) { { number: 1, type: :supplement, base: Identifier.create(sector: "T", series: "H", number: 1) } }

        # Annex to ITU-T OB.1283 (01/2024)
        it "renders identifier" do
          expect(subject.to_s).to eq("ITU-T OB No. #{number} (01/2024)")
        end
      end

      context "Annex to Special Publication" do
        let(:series) { nil }
        let(:number) { nil }
        let(:params) do
          { type: :annex,
            base: Identifier.create(sector: "T", series: "OB", number: 1) }
        end

        it "renders annex to identifier" do
          expect(subject.to_s).to eq("Annex to ITU-T OB No. 1")
        end
      end

      # Fixtures from metanorma-itu PR #497 (spec/metanorma/i18n_spec.rb).
      # Three forms per language: default English, short with token
      # translations, and long title-style template.
      #
      # The identifier's `language:` attribute is the document's own language
      # (drives the trailing "-F"/"-S" suffix). The `to_s(i18n_lang:)` kwarg
      # is independent — it controls translation of identifier text. Caller
      # pattern from metanorma-itu front_id.rb#itu_id_lang sets both to the
      # same value (recursively, including the base), but the API supports
      # mismatching them too — see "differentiates document language" below.
      describe "Annex to Special Publication with language" do
        let(:series) { nil }
        let(:number) { nil }
        let(:base_id) do
          Identifier.create(sector: "T", series: "OB", number: 1000,
                            language: lang)
        end

        subject do
          described_class.create(type: :annex, base: base_id, language: lang)
        end

        context "French (fr)" do
          let(:lang) { "fr" }

          it "renders short form" do
            expect(subject.to_s(i18n_lang: :fr))
              .to eq("Annexe au UIT-T OB No. 1000-F")
          end

          it "renders long form" do
            expect(subject.to_s(i18n_lang: :fr, format: :long))
              .to eq("Annexe au BE de l'UIT 1000-F")
          end
        end

        context "Spanish (es)" do
          let(:lang) { "es" }

          it "renders short form" do
            expect(subject.to_s(i18n_lang: :es))
              .to eq("Anexo al UIT-T OB No. 1000-S")
          end

          it "renders long form" do
            expect(subject.to_s(i18n_lang: :es, format: :long))
              .to eq("Anexo al BE de la UIT N.º 1000-S")
          end
        end

        context "Arabic (ar)" do
          let(:lang) { "ar" }

          it "renders short form" do
            expect(subject.to_s(i18n_lang: :ar))
              .to eq("ITU-T OB No. 1000 ملحق-A")
          end

          it "renders long form" do
            expect(subject.to_s(i18n_lang: :ar, format: :long))
              .to eq("ملحق ابلنشرة التشغيلية رقم 1000-A")
          end
        end

        context "Russian (ru)" do
          let(:lang) { "ru" }

          it "renders short form (template-based)" do
            expect(subject.to_s(i18n_lang: :ru))
              .to eq("Приложение к ОБ МСЭ 1000-R")
          end

          it "renders long form" do
            expect(subject.to_s(i18n_lang: :ru, format: :long))
              .to eq("Приложение к ОБ МСЭ 1000-R")
          end
        end

        context "Chinese (zh)" do
          let(:lang) { "zh" }

          it "renders short form (template-based)" do
            expect(subject.to_s(i18n_lang: :zh))
              .to eq("国际电联操作公报附件 第 1000 期-C")
          end

          it "renders long form" do
            expect(subject.to_s(i18n_lang: :zh, format: :long))
              .to eq("国际电联操作公报附件 第 1000 期-C")
          end
        end

        context "default (no language) keeps English" do
          let(:lang) { nil }
          let(:base_id) do
            Identifier.create(sector: "T", series: "OB", number: 1000)
          end
          subject do
            described_class.create(type: :annex, base: base_id)
          end

          it "renders English form regardless of to_s language opt" do
            expect(subject.to_s).to eq("Annex to ITU-T OB No. 1000")
          end
        end

        context "differentiates document language from rendering language" do
          # Per @opoudjis on PR #38: document language and identifier text
          # language are distinct concerns. A French-language document may be
          # cited in English text with the "-F" suffix preserved.
          let(:lang) { "fr" }

          it "renders English text with French suffix when i18n_lang=:en" do
            expect(subject.to_s(i18n_lang: :en))
              .to eq("Annex to ITU-T OB No. 1000-F")
          end

          it "still translates when i18n_lang matches document language" do
            expect(subject.to_s(i18n_lang: :fr))
              .to eq("Annexe au UIT-T OB No. 1000-F")
          end
        end

        context "language: kwarg on to_s remains accepted as deprecated alias" do
          let(:lang) { "fr" }

          it "treats language: as i18n_lang:" do
            expect(subject.to_s(language: :fr))
              .to eq("Annexe au UIT-T OB No. 1000-F")
          end
        end
      end
    end
  end
end
