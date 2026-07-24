# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Itu::Identifiers::Question do
  shared_examples "a round-trippable question" do |id|
    subject { id }

    let(:parsed) { Pubid::Itu.parse(subject) }

    it "parses as Question" do
      expect(parsed).to be_a(described_class)
    end

    it "round-trips" do
      expect(parsed.to_s).to eq(subject)
    end

    it "carries the question _type" do
      expect(parsed.to_hash["_type"]).to eq("pubid:itu:question")
    end

    it "round-trips through hash" do
      hash = parsed.to_hash
      expect(Pubid::Itu::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end

  describe "numeric questions" do
    context "ITU-R 234-1/7:" do
      subject { "ITU-R 234-1/7:" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses sector" do
        expect(parsed.sector.sector).to eq("R")
      end

      it "has no series" do
        expect(parsed.series).to be_nil
      end

      it "parses number" do
        expect(parsed.code.number).to eq("234")
      end

      it "parses part" do
        expect(parsed.code.parts).to eq(["1"])
      end

      it "parses study group" do
        expect(parsed.study_group).to eq("7")
      end

      it "has a trailing colon" do
        expect(parsed.has_colon).to be(true)
      end
    end

    it_behaves_like "a round-trippable question", "ITU-R 234-1/7:"
    it_behaves_like "a round-trippable question", "ITU-R 37-7/5:"
    it_behaves_like "a round-trippable question", "ITU-R 237/3:"
  end

  describe "letter-series questions" do
    context "ITU-R P.3/BL/7" do
      subject { "ITU-R P.3/BL/7" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("P")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("3")
      end

      it "parses study group" do
        expect(parsed.study_group).to eq("7")
      end

      it "flags the /BL/ segment" do
        expect(parsed.has_bl).to be(true)
      end

      it "is not bracketed" do
        expect(parsed.bracketed).to be(false)
      end

      it "has no trailing colon" do
        expect(parsed.has_colon).to be(false)
      end
    end

    context "ITU-R S.[4/BL/2]:" do
      subject { "ITU-R S.[4/BL/2]:" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "flags bracketed" do
        expect(parsed.bracketed).to be(true)
      end

      it "flags the /BL/ segment" do
        expect(parsed.has_bl).to be(true)
      end

      it "has a trailing colon" do
        expect(parsed.has_colon).to be(true)
      end
    end

    it_behaves_like "a round-trippable question", "ITU-R P.3/BL/7"
    it_behaves_like "a round-trippable question", "ITU-R SM.1/30"
    it_behaves_like "a round-trippable question", "ITU-R S.[4/BL/2]:"
    it_behaves_like "a round-trippable question", "ITU-R M.5/BL/10:"
    it_behaves_like "a round-trippable question", "ITU-R P.[3/BL/1]"
  end
end
