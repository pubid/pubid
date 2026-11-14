# frozen_string_literal: true

require "spec_helper"

# IEC house style puts a space, not a slash, between the publisher and the
# typed-stage abbreviation: "IEC PNW 1000-1:2023", not "IEC/PNW 1000-1:2023".
# pubid-iec 1.x rendered a space for every type and rejected the slash form
# outright. pubid 2 rendered a slash for International Standards, amendments,
# corrigenda and interpretation sheets, while about a dozen per-type classes
# overrode the base to force a space — so the flavor disagreed with itself.
#
# Both spellings stay ACCEPTED on input. Only rendering normalises.
#
# See https://github.com/pubid/pubid/issues/360 item 2.
RSpec.describe "IEC stage separator" do
  describe "rendering" do
    {
      "IEC/CD 60038" => "IEC CD 60038",
      "IEC CD 60038" => "IEC CD 60038",
      "IEC/CDV 60038" => "IEC CDV 60038",
      "IEC/FDIS 60038" => "IEC FDIS 60038",
      "IEC/NP 60038" => "IEC NP 60038",
      # The legacy prefix faces decode onto the modern identity (owner
      # ruling 2026-11-12), so their render is the modern on-base face —
      # the spaced ballot face for a draft stage (owner ruling
      # 2026-11-14: the stored/citation twins are "/FDAM 1", "/DCOR 1").
      "IEC/FDAM 60038-1" => "IEC 60038-1/FDAM 1",
      "IEC/DCOR 60038-1" => "IEC 60038-1/DCOR 1",
      "IEC/DISH 60050-191" => "IEC 60050-191/DISH 1",
      # Already rendered with a space by a per-type override; must not move.
      "IEC TS 60038" => "IEC TS 60038",
      "IEC/DTR 62048" => "IEC DTR 62048",
      # A copublisher list keeps its slashes; only the stage separator changes.
      "ISO/IEC 27001" => "ISO/IEC 27001",
      "IEC/IEEE 82079-1" => "IEC/IEEE 82079-1",
    }.each do |input, expected|
      it "renders #{input.inspect} as #{expected.inspect}" do
        expect(Pubid::Iec.parse(input).to_s).to eq(expected)
      end
    end
  end

  describe "input acceptance" do
    [
      %w[IEC/CD\ 60038 IEC\ CD\ 60038],
      ["IEC/FDIS 60038", "IEC FDIS 60038"],
      ["IEC/FDAM 60038-1", "IEC FDAM 60038-1"],
    ].each do |slash, space|
      it "parses #{slash.inspect} and #{space.inspect} alike" do
        from_slash = Pubid::Iec.parse(slash)
        from_space = Pubid::Iec.parse(space)

        expect(from_slash.to_s).to eq(from_space.to_s)
        expect(from_slash.to_hash).to eq(from_space.to_hash)
      end
    end

    # Both faces of the old notation are one identity: the modern on-base
    # form (the owner's decode ruling).
    it "decodes both FDAM faces onto the modern on-base form" do
      expect(Pubid::Iec.parse("IEC/FDAM 60038-1"))
        .to eq(Pubid::Iec.parse("IEC 60038-1/FDAM 1"))
    end
  end

  # The PAS override built its prefix from `publisher.to_s` with no copublisher
  # handling and no `super`, so a copublished PAS lost the IEC half from both
  # the printed form and the URN. Deleting the override repairs it.
  describe "copublished documents keep every publisher" do
    it "keeps IEC on a copublished PAS" do
      id = Pubid::Iec.parse("ISO/IEC PAS 62975")

      expect(id.to_s).to eq("ISO/IEC PAS 62975")
      expect(id.to_urn).to include("iso-iec")
    end
  end

  it "renders every stage form as a fixed point" do
    inputs = ["IEC/CD 60038", "IEC/FDIS 60038", "IEC/FDAM 60038-1",
              "IEC/DCOR 60038-1", "IEC/DISH 60050-191", "ISO/IEC PAS 62975",
              "IEC PNW 1000-1:2023 ED2"]

    inputs.each do |input|
      once = Pubid::Iec.parse(input).to_s
      expect(Pubid::Iec.parse(once).to_s).to eq(once)
    end
  end

  # Draft-stage supplements print the ballot face: stage token, SPACE,
  # number ("60038-1/FDAM 1") — the spaced citation form the stored
  # twins carry (ISO corpus /FDAM 1, /PDAM 1, /FPDAM 2, /DCOR 1.3,
  # /DISH 1 …). The published stages keep the glued corpus-dominant
  # face ("60038-1/AMD1:2011"). The discriminator is the typed stage's
  # own published mark (stage_code :published), not a token list.
  describe "draft vs published supplement faces" do
    {
      # Draft stages: spaced.
      "IEC 60038-1/FDAM 1" => "IEC 60038-1/FDAM 1",
      "IEC 60038-1/DAM 1" => "IEC 60038-1/DAM 1",
      "ISO/IEC 12207/PDAM 1" => "ISO/IEC 12207/PDAM 1",
      "ISO/IEC 9075-1/FPDAM 1" => "ISO/IEC 9075-1/FPDAM 1",
      "IEC 60038-1/DCOR 1" => "IEC 60038-1/DCOR 1",
      "IEC 60038-1/FDCOR 1" => "IEC 60038-1/FDCOR 1",
      "IEC 60038-1/DISH 1" => "IEC 60038-1/DISH 1",
      "IEC 60050-191/CDISH 1" => "IEC 60050-191/CDISH 1",
      # Published stages: glued.
      "IEC 60038:2009/AMD1:2011" => "IEC 60038:2009/AMD1:2011",
      "IEC 60038:2009/COR1:2011" => "IEC 60038:2009/COR1:2011",
      "IEC 60038-1/ISH1" => "IEC 60038-1/ISH1",
    }.each do |input, expected|
      it "renders #{input.inspect} as #{expected.inspect}" do
        expect(Pubid::Iec.parse(input).to_s).to eq(expected)
      end
    end
  end
end
