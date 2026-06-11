# frozen_string_literal: true

require "spec_helper"

# Verifies the `data/iso/update_codes.yaml` regex normalizations applied
# by `Pubid::Iso.parse` (via `Pubid::Iso::Normalizer.apply`).
#
# `DIS` and `FDIS` are typed-stages of the IS class only — for TR/TS/PAS/ISP
# they have dedicated `D<type>` / `FD<type>` typed-stage abbrs (e.g. `DTR`,
# `FDPAS`, `DISP`). The long forms `DIS TR`, `FDIS PAS`, `DIS ISP` are
# rewritten to those canonical short forms before parsing. Likewise for
# supplement-position long forms (`DIS Cor` → `DCOR`, `DIS Suppl` → `DSuppl`,
# `DIS Add` → `DAD`, etc.).
RSpec.describe "ISO update_codes normalizations" do
  shared_examples "normalizes to" do |original, canonical|
    it "rewrites #{original.inspect} → #{canonical.inspect}" do
      expect(Pubid::Iso.parse(original).to_s).to eq(canonical)
    end
  end

  describe "DIS|FDIS <type> long forms" do
    include_examples "normalizes to", "ISO/IEC DIS ISP 12060-6", "ISO/IEC DISP 12060-6"
    include_examples "normalizes to", "ISO/IEC FDIS ISP 12060-6", "ISO/IEC FDISP 12060-6"
    include_examples "normalizes to", "ISO/IEC DIS TR 14143-5", "ISO/IEC DTR 14143-5"
    include_examples "normalizes to", "ISO/IEC DIS PAS 1", "ISO/IEC DPAS 1"
    include_examples "normalizes to", "ISO/IEC FDIS PAS 1", "ISO/IEC FDPAS 1"
    include_examples "normalizes to", "ISO/IEC DIS TS 5008", "ISO/IEC DTS 5008"
  end

  describe "DIS|FDIS <supplement-type> long forms" do
    include_examples "normalizes to", "ISO 8327:1987/DIS Add 2", "ISO 8327:1987/DAD 2"
    include_examples "normalizes to",
                     "ISO/IEC Guide 98:1993/DIS Suppl 1.2",
                     "ISO/IEC Guide 98:1993/DSuppl 1.2"
    include_examples "normalizes to",
                     "ISO/IEC 19757-2:2003/Amd 1:2006/DIS Cor 1",
                     "ISO/IEC 19757-2:2003/AMD 1:2006/DCOR 1"
  end

  describe "negatives — must NOT be rewritten" do
    # FDIS Suppl is itself a canonical typed-stage abbr (in TYPED_STAGES_SUPPLEMENTS)
    # and gets rendered as the short form FDSuppl by the renderer, not by update_codes.
    it "leaves canonical short forms untouched" do
      expect(Pubid::Iso.parse("ISO/IEC ISP 12060-6").to_s).to eq("ISO/IEC ISP 12060-6")
      expect(Pubid::Iso.parse("ISO/IEC WD ISP 11182-3").to_s).to eq("ISO/IEC WD ISP 11182-3")
      expect(Pubid::Iso.parse("ISO 9000/Amd 1").to_s).to eq("ISO 9000/Amd 1")
    end
  end
end
