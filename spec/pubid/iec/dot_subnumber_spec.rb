# frozen_string_literal: true

# The dotted sub-number of an IEC draft supplement (pubid#725). The ballot
# faces print it — "/DAM 2.3:2022", "/DCOR 1.3" on the base, and the
# dotted base designation "60038-2.3" in the ballot-prefix faces — and the
# ISO flavor has always kept its dot. The IEC losses were build-side (the
# builder dropped supp_stage_iteration) and render-side (the supplement
# and base number portions dropped the facet); the grammar token now
# admits the multi-digit run (\.\d+).
#
# The facet is ISO's `stage_iteration` (Components::Iteration) on the
# layer whose designation carries the dot: on the SUPPLEMENT for the
# on-base draft faces, on the BASE for the ballot-prefix faces and the
# plain dotted base.
RSpec.describe "IEC dotted supplement sub-number" do
  describe "on-base draft faces" do
    rows = {
      # input => [render, iteration, number, klass]
      "IEC 60038-2/DAM 2.3:2022" =>
        ["IEC 60038-2/DAM 2.3:2022", "3", "2", Pubid::Iec::Identifiers::Amendment],
      "IEC 60038-2/DCOR 1.3" =>
        ["IEC 60038-2/DCOR 1.3", "3", "1", Pubid::Iec::Identifiers::Corrigendum],
      # The token admits the multi-digit run (\.\d+).
      "IEC 60038-2/DAM 2.11:2022" =>
        ["IEC 60038-2/DAM 2.11:2022", "11", "2", Pubid::Iec::Identifiers::Amendment],
    }.freeze

    rows.each do |input, (render, iteration, number, klass)|
      context input do
        let(:id) { Pubid::Iec.parse(input) }
        let(:back) { Pubid::Iec::Identifier.from_hash(id.to_hash) }

        it "parses to #{klass.name.split('::').last}" do
          expect(id).to be_a(klass)
        end

        it "keeps the sub-number on the supplement" do
          expect(id.stage_iteration.render).to eq(iteration)
          expect(id.number).to eq(number)
        end

        it "renders the spaced dotted ballot face" do
          expect(id.to_s).to eq(render)
        end

        it "is == its from_hash(to_hash) round trip" do
          expect(back).to eq(id)
          expect(back.to_s).to eq(render)
        end

        it "carries the facet in both URN schemes" do
          expect(id.to_pubid_urn).to end_with("iter-#{iteration}")
          expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
          # The official URN rides the dotted number in the supplement's
          # number slot; parsing it back keeps the facet.
          token = klass == Pubid::Iec::Identifiers::Corrigendum ? "cor" : "amd"
          expect(id.to_urn).to include(":#{token}:#{number}.#{iteration}:")
          rebuilt = Pubid::Iec.parse_urn(id.to_urn)
          expect(rebuilt.stage_iteration.render).to eq(iteration)
        end

        it "re-parses its own render to the same identifier" do
          expect(Pubid::Iec.parse(id.to_s)).to eq(id)
        end
      end
    end
  end

  describe "ballot-prefix faces with a dotted base designation" do
    # The designation stays whole on the base: "IEC/FDAM 60038-2.3" is
    # base 60038-2 with stage iteration 3 — the same identity the plain
    # on-base parse of "IEC 60038-2.3" holds — plus the implied FDAM 1.
    legacy_faces = {
      "IEC/FDAM 60038-2.3" => "IEC 60038-2.3/FDAM 1",
      "IEC FDAM 60038-2.3" => "IEC 60038-2.3/FDAM 1",
      "IEC DAM 60038-2.3" => "IEC 60038-2.3/DAM 1",
    }.freeze

    legacy_faces.each do |input, modern|
      context input do
        let(:id) { Pubid::Iec.parse(input) }
        let(:modern_id) { Pubid::Iec.parse(modern) }

        it "decodes onto the modern on-base parse" do
          expect(id).to eq(modern_id)
          expect(id.to_hash).to eq(modern_id.to_hash)
        end

        it "carries the dot on the BASE, not the supplement" do
          expect(id.base.stage_iteration.render).to eq("3")
          expect(id.stage_iteration).to be_nil
        end

        it "renders the dotted base with the implied numbered supplement" do
          expect(id.to_s).to eq(modern)
        end

        it "is == its from_hash(to_hash) round trip" do
          expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
        end

        it "re-parses its own render to the same identifier" do
          expect(Pubid::Iec.parse(id.to_s)).to eq(id)
        end
      end
    end
  end

  describe "the plain dotted base" do
    let(:id) { Pubid::Iec.parse("IEC 60038-2.3") }
    let(:back) { Pubid::Iec::Identifier.from_hash(id.to_hash) }

    it "keeps the sub-number losslessly at parse" do
      expect(id.stage_iteration.render).to eq("3")
      expect(id.number).to eq("60038")
      expect(id.part).to eq("2")
    end

    # The render used to drop the dot while to_hash carried it — the
    # identifier rendered AS its sub-number-less twin.
    it "renders the dot" do
      expect(id.to_s).to eq("IEC 60038-2.3")
    end

    it "is == its from_hash(to_hash) round trip" do
      expect(back).to eq(id)
      expect(back.to_s).to eq("IEC 60038-2.3")
    end

    it "carries the facet in the pubid-scheme URN" do
      expect(id.to_pubid_urn).to eq("urn:pubid:iec:is:60038:part-2:iter-3")
      expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
    end

    it "re-parses its own render to the same identifier" do
      expect(Pubid::Iec.parse(id.to_s)).to eq(id)
    end
  end

  describe "unattested dotted ballot-number faces stay raising" do
    # The ballot-prefix faces print the ballot NUMBER undotted ("ISO/IEC
    # PDAM 2 10646:2012"); a dotted ballot number is attested only on the
    # ON-BASE faces, so the prefix-face dotted number keeps raising rather
    # than guessing an identity for a spelling no source prints.
    ["IEC/DCOR 1.3 60038-2", "ISO/IEC PDAM 2.3 10646:2012"].each do |input|
      it "raises for #{input.inspect}" do
        expect { Pubid::Iec.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  # pubid#727: the standalone (no-base, no-part) face with a dotted number —
  # "IEC/AMD 1.2:2017". The shape parsed and then LOST the dot at render:
  # render_supplement_standalone prints the base number and the supplement
  # number only, so the stored stage_iteration was dropped and
  # parse(to_s) != parse. No IEC source prints a no-part standalone face
  # with a dotted number (the facet is attested only on the on-base draft
  # faces), so the shape is rejected at parse — the same ruling as the
  # prefix-face dotted ballot numbers above — rather than left building an
  # identifier whose canonical face cannot carry its own stored facet.
  describe "the standalone no-part dotted face is rejected at parse" do
    raising = [
      "IEC/AMD 1.2:2017", "IEC/AMD 1.2",
      "IEC/COR 1.2:2017",
      "IEC/DCOR 1.3:2017", "IEC/DCOR 1.3",
      "IEC/DISH 1.2:2017",
      # the mixed-case token and the publisher-less and copublished
      # spellings bind the same standalone layout
      "IEC/Amd 1.2:2017", "AMD 1.2:2017", "ISO/IEC/AMD 1.2:2017",
      # a dotted layer under an undotted second supplement rides the same
      # self-base face one level down
      "IEC/AMD 1.2:2017/COR 1:2018"
    ].freeze

    raising.each do |input|
      it "raises for #{input.inspect}" do
        expect { Pubid::Iec.parse(input) }
          .to raise_error(Pubid::Errors::ParseError, /dotted sub-number/)
      end
    end

    it "reports the input and flavor on the synthetic raise" do
      expect { Pubid::Iec.parse("IEC/AMD 1.2:2017") }
        .to raise_error(Pubid::Errors::ParseError) do |error|
          expect(error.input).to eq("IEC/AMD 1.2:2017")
          expect(error.flavor).to eq("iec")
          expect(error.parse_failure_cause).to be_nil
        end
    end
  end

  describe "faces that keep their dot on a printable layer keep parsing" do
    # Every parseable neighbour of the rejected shape, probed on #727:
    # the single-document draft faces carry the dot on the BASE (they are
    # not supplements), the DAM-family prefix faces decode the dotted
    # designation onto the base, and the on-base faces have a real base —
    # all of them render the dot and re-parse to the same identifier.
    keep = {
      "IEC/CD 1.2:2017" => "IEC CD 1.2:2017",
      "IEC/FDIS 1.2:2017" => "IEC FDIS 1.2:2017",
      "IEC/DTR 1.2:2017" => "IEC DTR 1.2:2017",
      "IEC/DTS 1.2:2017" => "IEC DTS 1.2:2017",
      "IEC/DAM 1.2" => "IEC 1.2/DAM 1",
      "IEC/FDAM 1.2:2017" => "IEC 1.2:2017/FDAM 1",
      "IEC/DAM 2.3:2022" => "IEC 2.3:2022/DAM 1",
      "IEC 60038-2/DAM 2.3:2022" => "IEC 60038-2/DAM 2.3:2022",
      "IEC 60038-2/DCOR 1.3" => "IEC 60038-2/DCOR 1.3",
      "IEC/FDAM 60038-2.3" => "IEC 60038-2.3/FDAM 1",
      "IEC/AMD 60038-1:2017" => "IEC 60038-1:2017/AMD1",
    }.freeze

    keep.each do |input, render|
      context input do
        let(:id) { Pubid::Iec.parse(input) }

        it "renders #{render.inspect}" do
          expect(id.to_s).to eq(render)
        end

        it "is == its from_hash(to_hash) round trip" do
          expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
        end

        it "re-parses its own render to the same identifier" do
          expect(Pubid::Iec.parse(id.to_s)).to eq(id)
        end
      end
    end
  end

  describe "the undotted standalone faces keep parsing" do
    # The render of the self-base standalone prints its number twice (the
    # documented #693 residue: "IEC/AMD 1:2017" renders "IEC Amd 1-1:2017",
    # which re-parses as Amd 1 of base 1-1) — unchanged by #727, which
    # rejects only the DOTTED standalone face.
    keep = {
      "IEC/AMD 1:2017" => "IEC Amd 1-1:2017",
      "IEC/AMD 1" => "IEC Amd 1-1",
      "IEC/DCOR 1:2017" => "IEC DCOR 1-1:2017",
      "IEC/DISH 1:2017" => "IEC DISH 1-1:2017",
    }.freeze

    keep.each do |input, render|
      context input do
        let(:id) { Pubid::Iec.parse(input) }

        it "renders #{render.inspect}" do
          expect(id.to_s).to eq(render)
        end

        it "is == its from_hash(to_hash) round trip" do
          expect(Pubid::Iec::Identifier.from_hash(id.to_hash)).to eq(id)
        end
      end
    end
  end

  describe "a pre-#727 stored hash still deserializes (deliberate residue)" do
    # from_hash is the deserialization path: a hash produced by a pre-#727
    # parse (the shape parsed before the reject) still builds. No published
    # relaton-data-iec row carries the shape — no source prints the face —
    # so nothing stored moves; the built object renders the undotted self-
    # base face, as it always did. Parse rejects the shape instead, so no
    # NEW hash of this shape can be produced by parsing.
    let(:id) do
      stored = {
        "_type" => "pubid:iec:amendment", "stage_iteration" => "2",
        "number" => "1", "year" => "2017"
      }
      Pubid::Iec::Identifier.from_hash(stored)
    end

    it "builds the amendment" do
      expect(id).to be_a(Pubid::Iec::Identifiers::Amendment)
    end

    it "renders the undotted self-base face" do
      expect(id.to_s).to eq("IEC Amd 1-1:2017")
    end
  end
end
