# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Isbn::Identifier do
  describe ".parse" do
    context "ISBN-13 with hyphens" do
      subject(:parsed) { described_class.parse("ISBN 978-3-16-148410-0") }

      it "captures raw" do
        expect(parsed.raw).to eq("9783161484100")
      end

      it "exposes form" do
        expect(parsed.form).to eq(:isbn13)
      end

      it "is valid" do
        expect(parsed).to be_valid
      end

      it "round-trips with hyphens preserved" do
        expect(parsed.to_s).to eq("ISBN 978-3-16-148410-0")
      end
    end

    context "ISBN-10 with colon prefix" do
      it "round-trips" do
        parsed = described_class.parse("ISBN: 0-306-40615-2")
        expect(parsed.form).to eq(:isbn10)
        expect(parsed.to_s).to eq("ISBN 0-306-40615-2")
      end
    end

    context "bare digits (no ISBN prefix)" do
      it "parses 13-digit form" do
        parsed = described_class.parse("9783161484100")
        expect(parsed.raw).to eq("9783161484100")
      end
    end

    it "raises on invalid check digit" do
      expect { described_class.parse("ISBN 978-3-16-148410-1") }
        .to raise_error(/check digit invalid/)
    end

    it "raises on wrong length" do
      expect { described_class.parse("ISBN 12345") }.to raise_error(/Failed to parse/)
    end
  end
end
