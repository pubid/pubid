# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Isbn::CheckDigit do
  describe ".compute_isbn10" do
    it "computes the correct digit for a known payload" do
      expect(described_class.compute_isbn10("030640615")).to eq("2")
    end

    it "returns X for payload that needs check digit 10" do
      # 123456789 → weighted sum 210 → (11 - 210%11) % 11 = 10 → "X"
      expect(described_class.compute_isbn10("123456789")).to eq("X")
    end

    it "raises on wrong-length payload" do
      expect { described_class.compute_isbn10("123") }.to raise_error(ArgumentError)
    end
  end

  describe ".compute_isbn13" do
    it "computes the correct digit for a known payload" do
      expect(described_class.compute_isbn13("978316148410")).to eq("0")
    end

    it "raises on wrong-length payload" do
      expect { described_class.compute_isbn13("123") }.to raise_error(ArgumentError)
    end
  end

  describe ".valid?" do
    it "validates a correct ISBN-10" do
      expect(described_class).to be_valid("0306406152")
    end

    it "validates a correct ISBN-13" do
      expect(described_class).to be_valid("9783161484100")
    end

    it "rejects an ISBN-10 with wrong check digit" do
      expect(described_class).not_to be_valid("0306406153")
    end

    it "rejects an ISBN-13 with wrong check digit" do
      expect(described_class).not_to be_valid("9783161484101")
    end

    it "rejects wrong length entirely" do
      expect(described_class).not_to be_valid("12345")
    end
  end
end
