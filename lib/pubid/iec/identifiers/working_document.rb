# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Working Document identifier class
      # Single Responsibility: Represents IEC Working Documents with TC attribution
      # Also handles Working Programmes with PWI/PNW stage-first format
      # Formats:
      #   Working Programme: "PWI TR 100-36 ED1"
      #   Working Document: "100/3705(F)/FDIS"
      class WorkingDocument < Base
        attribute :technical_committee, :string, default: -> {}
        attribute :wd_language, :string, default: -> {}
        attribute :wd_stage, :string, default: -> {}
        attribute :wp_stage, :string, default: -> {}
        attribute :wp_type, :string, default: -> {}

        # The working document's identity attributes are plain strings, so no
        # converter is needed: lutaml writes the scalar, and
        # ::Pubid::Identifier#to_hash drops a nil (the `-> {}` defaults are
        # nil). This is the serialization that issue #687 restored — before
        # it, `to_hash` was `{"_type" => "pubid:iec:working-document"}` alone,
        # all 2,318 working documents shared one hash and one URN
        # (`urn:pubid:iec:wd`), and no row of this class ever matched after a
        # from_hash round trip.
        key_value do
          map "technical_committee", to: :technical_committee,
                                     render_default: false
          map "wd_language", to: :wd_language, render_default: false
          map "wd_stage", to: :wd_stage, render_default: false
          map "wp_stage", to: :wp_stage, render_default: false
          map "wp_type", to: :wp_type, render_default: false
        end

        # Working documents have no TYPED_STAGES - they use PROJECT_STAGES only
        TYPED_STAGES = [].freeze

        # Working document stages
        PROJECT_STAGES = {}.freeze

        def self.type
          { key: :wd,
            web: :working_document, title: "Working Document", short: "WD" }
        end

        # A working document prints its committee, number, language and stage —
        # `1/2457(F)/FDIS` — and the document number is the inherited
        # `number` (issue #687: it used to sit in a parallel `wd_number`
        # attribute that nothing serialized). `wd_stage` is the printed stage
        # token ("FDIS"); the derived `#stage` reader covers only the PWI/PNW
        # work-programme form and is nil here.
        def annotation_tokens
          super + [
            [:technical_committee, "docnumber"],
            [:number, "docnumber"],
            [:wd_language, "language"],
            [:wd_stage, "stage"],
            [:wp_stage, "stage"],
            [:wp_type, "doctype"],
          ]
        end

        # Return stage object for the PWI/PNW work-programme stage.
        #
        # This used to build a bare Stage from a hand-written abbreviation map,
        # so the stage carried no harmonized code and "pnw" existed as a stage
        # code nowhere else in the registry. It now resolves through the shared
        # registry, so PWI carries 00.* and PNW carries 10.20 — which is what
        # the URN generator reads.
        def stage
          return nil unless wp_stage

          @stage ||= Pubid::Iec.locate_stage(wp_stage)&.to_stage
        end
      end
    end
  end
end
