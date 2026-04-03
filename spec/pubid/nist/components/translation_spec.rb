# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Components::Translation do
  describe "initialization" do
    it "creates translation with code" do
      translation = described_class.new(code: "spa")
      expect(translation.code).to eq("spa")
    end

    it "creates translation with 3-letter ISO 639-2 code" do
      translation = described_class.new(code: "por")
      expect(translation.code).to eq("por")
    end

    it "creates translation with indonesian code" do
      translation = described_class.new(code: "ind")
      expect(translation.code).to eq("ind")
    end
  end

  describe "#to_s" do
    context "short format" do
      it "renders spanish code with leading space" do
        translation = described_class.new(code: "spa")
        expect(translation.to_s(:short)).to eq(" spa")
      end

      it "renders portuguese code with leading space" do
        translation = described_class.new(code: "por")
        expect(translation.to_s(:short)).to eq(" por")
      end

      it "renders indonesian code with leading space" do
        translation = described_class.new(code: "ind")
        expect(translation.to_s(:short)).to eq(" ind")
      end

      it "renders chinese code with leading space" do
        translation = described_class.new(code: "chi")
        expect(translation.to_s(:short)).to eq(" chi")
      end
    end

    context "mr format" do
      it "renders spanish code with dot prefix" do
        translation = described_class.new(code: "spa")
        expect(translation.to_s(:mr)).to eq(".spa")
      end

      it "renders portuguese code with dot prefix" do
        translation = described_class.new(code: "por")
        expect(translation.to_s(:mr)).to eq(".por")
      end

      it "renders indonesian code with dot prefix" do
        translation = described_class.new(code: "ind")
        expect(translation.to_s(:mr)).to eq(".ind")
      end
    end

    context "long format" do
      it "renders same as short format" do
        translation = described_class.new(code: "spa")
        expect(translation.to_s(:long)).to eq(" spa")
      end

      it "renders portuguese in long format" do
        translation = described_class.new(code: "por")
        expect(translation.to_s(:long)).to eq(" por")
      end
    end

    context "default format" do
      it "uses short format when no format specified" do
        translation = described_class.new(code: "spa")
        expect(translation.to_s).to eq(" spa")
      end
    end

    context "nil code" do
      it "returns empty string when code is nil" do
        translation = described_class.new(code: nil)
        expect(translation.to_s).to eq("")
      end

      it "returns empty string for nil code in mr format" do
        translation = described_class.new(code: nil)
        expect(translation.to_s(:mr)).to eq("")
      end

      it "returns empty string for nil code in long format" do
        translation = described_class.new(code: nil)
        expect(translation.to_s(:long)).to eq("")
      end
    end
  end

  describe "common language codes" do
    it "supports spanish (spa)" do
      translation = described_class.new(code: "spa")
      expect(translation.code).to eq("spa")
    end

    it "supports portuguese (por)" do
      translation = described_class.new(code: "por")
      expect(translation.code).to eq("por")
    end

    it "supports indonesian (ind)" do
      translation = described_class.new(code: "ind")
      expect(translation.code).to eq("ind")
    end

    it "supports chinese (chi)" do
      translation = described_class.new(code: "chi")
      expect(translation.code).to eq("chi")
    end

    it "supports japanese (jpn)" do
      translation = described_class.new(code: "jpn")
      expect(translation.code).to eq("jpn")
    end

    it "supports korean (kor)" do
      translation = described_class.new(code: "kor")
      expect(translation.code).to eq("kor")
    end

    it "supports french (fre)" do
      translation = described_class.new(code: "fre")
      expect(translation.code).to eq("fre")
    end

    it "supports german (ger)" do
      translation = described_class.new(code: "ger")
      expect(translation.code).to eq("ger")
    end
  end
end
