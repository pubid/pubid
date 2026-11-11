# frozen_string_literal: true

require "spec_helper"

# MLIT publishes PLATEAU Handbook #00 edition 5.0 twice on one date: the
# main volume alone (本編) and the main volume with its appendix in one PDF
# (本編＋付録). The volume label is the only thing that tells them apart.
RSpec.describe Pubid::Plateau::Identifiers::Handbook do
  def parse(input)
    Pubid::Plateau.parse(input)
  end

  let(:plain) { "PLATEAU Handbook #00 第5.0版" }
  let(:main) { "PLATEAU Handbook #00 第5.0版 本編" }
  let(:appendix) { "PLATEAU Handbook #00 第5.0版 本編＋付録" }

  describe "volume label: parse and render" do
    {
      "PLATEAU Handbook #00 第5.0版 本編" =>
        ["PLATEAU Handbook #00 第5.0版 本編", "本編"],
      "PLATEAU Handbook #00 第5.0版　本編" =>
        ["PLATEAU Handbook #00 第5.0版 本編", "本編"],
      "PLATEAU Handbook #00 第5.0版 本編＋付録" =>
        ["PLATEAU Handbook #00 第5.0版 本編＋付録", "本編＋付録"],
      "PLATEAU Handbook #00 第5.0版　本編＋付録" =>
        ["PLATEAU Handbook #00 第5.0版 本編＋付録", "本編＋付録"],
      "PLATEAU Handbook #00 第5.0版 本編+付録" =>
        ["PLATEAU Handbook #00 第5.0版 本編＋付録", "本編＋付録"],
      "PLATEAU Handbook #00 第5.0版　本編+付録" =>
        ["PLATEAU Handbook #00 第5.0版 本編＋付録", "本編＋付録"],
      "PLATEAU Handbook #03-1 第5.0版 本編" =>
        ["PLATEAU Handbook #03-1 第5.0版 本編", "本編"],
    }.each do |input, (rendered, volume)|
      it "reads #{input.inspect} as volume #{volume}" do
        id = parse(input)
        expect(id).to be_a(described_class)
        expect(id.edition).to eq("5.0")
        expect(id.volume).to eq(volume)
        expect(id.to_s).to eq(rendered)
      end
    end

    it "leaves the volume nil and the render unchanged without a label" do
      id = parse(plain)
      expect(id.volume).to be_nil
      expect(id.to_s).to eq(plain)
    end

    it "prints no volume without an edition, so the render parses back" do
      rendered = parse(appendix).exclude(:edition).to_s
      expect(rendered).to eq("PLATEAU Handbook #00")
      expect(parse(rendered).to_s).to eq(rendered)
    end

    it "keeps the Handbook #11 split-edition mapping" do
      expect(parse("PLATEAU Handbook #11 第1.0版（公共活用編）").to_s)
        .to eq("PLATEAU Handbook #04 第1.0版")
    end
  end

  describe "volume label: serialization" do
    %w[plain main appendix].each do |name|
      it "round-trips the #{name} form through from_hash" do
        input = public_send(name)
        id = parse(input)
        back = Pubid::Plateau::Identifier.from_hash(id.to_hash)
        expect(back).to be_a(described_class)
        expect(back).to eq(id)
        expect(back.to_hash).to eq(id.to_hash)
        expect(back.to_s).to eq(input)
      end
    end

    it "writes the volume into the hash" do
      expect(parse(appendix).to_hash["volume"]).to eq("本編＋付録")
    end

    it "keeps the hash of an unlabelled handbook unchanged" do
      expect(parse(plain).to_hash).to eq(
        "_type" => "pubid:plateau:handbook",
        "number" => 0,
        "edition" => "5.0",
      )
    end

    it "round-trips the volume through the pubid-scheme URN" do
      id = parse(appendix)
      back = Pubid.parse_urn(id.to_pubid_urn)
      expect(back).to eq(id)
      expect(back.to_s).to eq(appendix)
    end
  end

  describe "volume label: equality and subset match" do
    it "separates an unlabelled edition from a labelled one" do
      expect(parse(plain)).not_to eq(parse(appendix))
      expect(parse(appendix)).not_to eq(parse(plain))
    end

    it "separates the two volume labels" do
      expect(parse(main)).not_to eq(parse(appendix))
    end

    it "equals itself across spellings" do
      expect(parse("PLATEAU Handbook #00 第5.0版　本編+付録"))
        .to eq(parse(appendix))
    end

    it "does not let an unlabelled reference subsume a labelled one" do
      candidate = parse(appendix)
      expect(parse(plain) === candidate).to be(false)
      expect(parse(main) === candidate).to be(false)
      expect(parse(appendix) === candidate).to be(true)
    end
  end
end
