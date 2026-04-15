# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # SI Standard (Système International) identifier
      # IEEE/ASTM SI standards for metric system
      # Handles both:
      # - SI: Published standards (IEEE/ASTM SI 10-1997)
      # - PSI: Proposed SI (drafts: IEEE/ASTM PSI 10/D2, October 2015)
      class SiStandard < Base
        # TYPED_STAGES for SI standards
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["SI"],
            type_code: "SI",
            stage_code: "published",
          ),
          Components::TypedStage.new(
            abbr: ["PSI"],
            type_code: "SI",
            stage_code: "draft",
          ),
        ].freeze

        # SI standards always have IEEE/ASTM publisher
        # Format: "IEEE/ASTM SI 10-1997" (published)
        #     or: "IEEE/ASTM PSI 10/D2, October 2015" (draft)

        # Use proper Draft component (Lutaml::Model object)
        attr_accessor :draft_obj

        def to_s
          parts = []

          # Publisher (IEEE/ASTM)
          parts << "IEEE/ASTM"

          # Type (SI or PSI based on typed_stage)
          parts << if typed_stage&.abbr&.include?("PSI")
                     "PSI"
                   else
                     "SI"
                   end

          # Code (number) with draft version for PSI
          code_part = code.to_s
          if draft_obj
            # Use Draft component's version attribute
            code_part += "/D#{draft_obj.version}"
          end
          parts << code_part if code

          # Date
          if month && year
            parts << ", #{month} #{year}"
          elsif year
            parts << "-#{year}"
          end

          # Relationships (if present)
          result = parts.join(" ")
          if relationships && !relationships.empty?
            rel_strs = relationships.map(&:to_s)
            result += " (#{rel_strs.join(' / ')})"
          end

          result
        end
      end
    end
  end
end
