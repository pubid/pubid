# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid/itu"

# "Annex to ITU OB" identifiers — the document IS the annex of a Special
# Publication (no annex number). Three rendering forms per PR #38:
#   * default (no i18n_lang): English structural
#   * short with i18n_lang: structural translation using `annex_to`
#   * long with format: :long: per-language `annex_long` template
#
# Fixtures sourced from metanorma-itu PR #497 spec/metanorma/i18n_spec.rb;
# treated as the authoritative source per @opoudjis on PR #38.
RSpec.describe Pubid::Itu::Identifiers::Annex do
  describe "round-trip parsing and rendering" do
    it "parses 'Annex to ITU OB No. 1'" do
      identifier = Pubid::Itu.parse("Annex to ITU OB No. 1")
      expect(identifier).to be_a(described_class)
      expect(identifier.to_s).to eq("Annex to ITU OB No. 1")
    end

    it "normalizes legacy 'Annex to ITU-T OB.1283 (01/2024)'" do
      identifier = Pubid::Itu.parse("Annex to ITU-T OB.1283 (01/2024)")
      expect(identifier.to_s).to eq("Annex to ITU OB No. 1283 (01/2024)")
    end
  end

  describe "i18n rendering with language" do
    let(:base_id) do
      Pubid::Itu::Identifier.create(series: "OB", number: 1000, language: lang)
    end
    let(:annex) do
      Pubid::Itu::Identifier.create(type: :annex, base: base_id, language: lang)
    end

    # French and Spanish use the long-form template for short rendering too
    # (per @opoudjis on PR #38): ITU itself uses the localized "BE"
    # abbreviation rather than mixing the English "OB" into French or Spanish
    # text. Short and long therefore produce the same string.
    context "French (fr)" do
      let(:lang) { "fr" }

      it "renders short form (matches long)" do
        expect(annex.to_s(i18n_lang: :fr))
          .to eq("Annexe au BE de l'UIT 1000-F")
      end

      it "renders long form" do
        expect(annex.to_s(i18n_lang: :fr, format: :long))
          .to eq("Annexe au BE de l'UIT 1000-F")
      end
    end

    context "Spanish (es)" do
      let(:lang) { "es" }

      it "renders short form (matches long)" do
        expect(annex.to_s(i18n_lang: :es))
          .to eq("Anexo al BE de la UIT N.º 1000-S")
      end

      it "renders long form" do
        expect(annex.to_s(i18n_lang: :es, format: :long))
          .to eq("Anexo al BE de la UIT N.º 1000-S")
      end
    end

    context "Arabic (ar)" do
      let(:lang) { "ar" }

      it "renders short form (annex_to translation as postfix)" do
        expect(annex.to_s(i18n_lang: :ar))
          .to eq("ITU OB No. 1000 ملحق-A")
      end

      it "renders long form" do
        expect(annex.to_s(i18n_lang: :ar, format: :long))
          .to eq("ملحق ابلنشرة التشغيلية رقم 1000-A")
      end
    end

    context "Russian (ru)" do
      let(:lang) { "ru" }

      it "renders short form (template-based)" do
        expect(annex.to_s(i18n_lang: :ru))
          .to eq("Приложение к ОБ МСЭ 1000-R")
      end

      it "renders long form" do
        expect(annex.to_s(i18n_lang: :ru, format: :long))
          .to eq("Приложение к ОБ МСЭ 1000-R")
      end
    end

    context "Chinese (zh)" do
      let(:lang) { "zh" }

      it "renders short form (template-based)" do
        expect(annex.to_s(i18n_lang: :zh))
          .to eq("国际电联操作公报附件 第 1000 期-C")
      end

      it "renders long form" do
        expect(annex.to_s(i18n_lang: :zh, format: :long))
          .to eq("国际电联操作公报附件 第 1000 期-C")
      end
    end

    # German is not an official ITU language so there is no `annex_long`
    # template and no language-suffix code. Only the "Annex to" prefix is
    # translated; the rest keeps the structural English form, with no suffix.
    context "German (de)" do
      let(:lang) { "de" }

      it "renders short form with German prefix and no suffix" do
        expect(annex.to_s(i18n_lang: :de))
          .to eq("Anhang zum ITU OB No. 1000")
      end
    end
  end

  describe "default (no language)" do
    let(:base_id) { Pubid::Itu::Identifier.create(series: "OB", number: 1000) }
    let(:annex) do
      Pubid::Itu::Identifier.create(type: :annex, base: base_id)
    end

    it "renders English form regardless of i18n_lang opt absence" do
      expect(annex.to_s).to eq("Annex to ITU OB No. 1000")
    end
  end

  describe "differentiates document language from rendering language" do
    # Per @opoudjis on PR #38: document language and identifier text language
    # are distinct concerns. A French-language document may be cited in
    # English text with the "-F" suffix preserved.
    let(:base_id) do
      Pubid::Itu::Identifier.create(series: "OB", number: 1000, language: "fr")
    end
    let(:annex) do
      Pubid::Itu::Identifier.create(type: :annex, base: base_id, language: "fr")
    end

    it "renders English text with French suffix when i18n_lang=:en" do
      expect(annex.to_s(i18n_lang: :en))
        .to eq("Annex to ITU OB No. 1000-F")
    end

    it "translates when i18n_lang matches document language" do
      expect(annex.to_s(i18n_lang: :fr))
        .to eq("Annexe au BE de l'UIT 1000-F")
    end
  end

  describe "deprecated `language:` kwarg on to_s" do
    let(:base_id) do
      Pubid::Itu::Identifier.create(series: "OB", number: 1000, language: "fr")
    end
    let(:annex) do
      Pubid::Itu::Identifier.create(type: :annex, base: base_id, language: "fr")
    end

    it "treats language: as i18n_lang:" do
      expect(annex.to_s(language: :fr))
        .to eq("Annexe au BE de l'UIT 1000-F")
    end
  end
end
