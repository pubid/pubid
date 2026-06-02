# frozen_string_literal: true

module Pubid
  module Nist
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "nist"]

        if identifier.series
          series = identifier.series.to_s
          parts << series.downcase
        elsif (sc = maybe(:series_code))
          parts << sc.downcase
        else
          parts << "sp"
        end

        identifier_parts = []

        if identifier.number
          number = identifier.number.to_s
          identifier_parts << number
        end

        if identifier.parts&.any?
          identifier_parts += identifier.parts.map { |p| "-#{p}" }
        end

        if identifier.edition
          identifier_parts << identifier.edition.to_s
        end

        if identifier.volume
          vol = identifier.volume.to_s
          identifier_parts << vol
        end

        if identifier.part && identifier.part
          identifier_parts << identifier.part.to_s
        end

        if identifier.volume && identifier.issue_number
          vol_str = identifier.volume.to_s
          issue_str = identifier.issue_number.to_s
          identifier_parts << "#{vol_str}n#{issue_str}"
        end

        if identifier.version_component
          identifier_parts << identifier.version_component.to_s
        elsif identifier.version
          identifier_parts << "ver.#{identifier.version}"
        end

        if identifier.update_component
          identifier_parts << identifier.update_component.to_s
        elsif identifier.update
          identifier_parts << "-upd#{identifier.update}"
        end

        if identifier.stage
          identifier_parts << identifier.stage.to_s
        end

        # Supplement is now a structured component. Preserve the existing URN
        # branching exactly: range → "supp{start}-{end}", revision → "supprev",
        # a valued supplement → "suppX"/"supp-X" (dash unless it starts with an
        # uppercase letter), and — quirk retained — a nil (absent) supplement
        # still emits "supp", while a present-but-empty one emits nothing.
        supp = identifier.supplement
        if supp&.range?
          identifier_parts << "supp#{supp.month}#{supp.year}-#{supp.month_end}#{supp.year_end}"
        elsif supp&.has_revision
          identifier_parts << "supprev"
        elsif supp && !supp.value_string.empty?
          value = supp.value_string
          identifier_parts << if value.match?(/^[A-Z]/)
                                "supp#{value}"
                              else
                                "supp-#{value}"
                              end
        elsif supp.nil?
          identifier_parts << "supp"
        end

        if identifier.errata
          identifier_parts << identifier.errata
        end

        if identifier.addendum || identifier.addendum_number
          identifier_parts << "add."
        end

        if identifier.draft_number
          identifier_parts << "#{identifier.draft_number}pd"
        elsif identifier.draft&.to_s&.include?("draft")
          identifier_parts << "-draft"
        end

        if identifier.index
          identifier_parts << "index"
        end

        if identifier.insert
          identifier_parts << "insert"
        end

        if identifier.section
          identifier_parts << "sec#{identifier.section}"
        end

        if identifier.appendix
          identifier_parts << "app"
        end

        parts << identifier_parts.join(".") unless identifier_parts.empty?

        if identifier.translation_component
          trans = identifier.translation_component
          lang = if trans&.language
                   trans.language
                 elsif trans.is_a?(String)
                   trans
                 end
          parts << lang.downcase if lang
        elsif identifier.translation
          parts << identifier.translation.downcase
        end

        parts.join(":")
      end
    end
  end
end
