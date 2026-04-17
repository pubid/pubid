# frozen_string_literal: true

module Pubid
  module Nist
    # Generates RFC 5141-bis compliant URNs from NIST identifiers
    #
    # URN format includes all components for full MR format convertibility:
    # urn:nist:{series}:{number-edition-volume-part-version-update-stage}:{translation}
    # Example: urn:nist:sp:800-53r5 for "NIST SP 800-53r5"
    # Example: urn:nist:sp:800-187.1.ipd for "NIST SP 800-187.1.ipd"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "nist"]

        # Series (SP, FIPS, IR, TN, NISTIR, etc.) - REQUIRED
        if identifier.respond_to?(:series) && identifier.series
          series = if identifier.series.respond_to?(:value)
                     identifier.series.value
                   else
                     identifier.series.to_s
                   end
          parts << series.downcase
        elsif identifier.respond_to?(:series_code)
          # Fallback to series_code method (defined in subclasses)
          parts << identifier.series_code.downcase
        else
          parts << "sp" # Default to SP
        end

        # Build identifier portion: number + edition + volume + part + version + update + stage
        # This matches the MR format: NIST.SP.800-53r5
        identifier_parts = []

        # Number (required)
        if identifier.respond_to?(:number) && identifier.number
          number = if identifier.number.respond_to?(:value)
                     identifier.number.value
                   else
                     identifier.number.to_s
                   end
          identifier_parts << number
        end

        # Parts (legacy parts collection for backward compatibility)
        if identifier.respond_to?(:parts) && identifier.parts&.any?
          identifier_parts += identifier.parts.map { |p| "-#{p}" }
        end

        # Edition component (e2, e2021, r5, etc.)
        if identifier.respond_to?(:edition) && identifier.edition
          edition = identifier.edition
          # Edition is attached directly without space: "800-53r5"
          if edition.respond_to?(:to_s)
            identifier_parts << edition.to_s
          end
        end

        # Volume component (v6)
        if identifier.respond_to?(:volume) && identifier.volume
          vol = if identifier.volume.respond_to?(:to_s)
                  identifier.volume.to_s
                else
                  "v#{identifier.volume}"
                end
          identifier_parts << vol
        end

        # Part component (n1, pt1)
        if identifier.respond_to?(:part) && identifier.part
          if identifier.part.respond_to?(:to_s)
          end
          prt = identifier.part.to_s
          identifier_parts << prt
        end

        # Volume + Issue number (v6n12 format)
        if identifier.respond_to?(:volume) && identifier.respond_to?(:issue_number) && identifier.volume && identifier.issue_number
          vol_str = identifier.volume.respond_to?(:to_s) ? identifier.volume.to_s : "v#{identifier.volume}"
          issue_str = identifier.issue_number.respond_to?(:to_s) ? identifier.issue_number.to_s : identifier.issue_number.to_s
          identifier_parts << "#{vol_str}n#{issue_str}"
        end

        # Version component
        if identifier.respond_to?(:version_component) && identifier.version_component
          ver = identifier.version_component.to_s
          identifier_parts << ver
        elsif identifier.respond_to?(:version) && identifier.version
          identifier_parts << "ver.#{identifier.version}"
        end

        # Update component
        if identifier.respond_to?(:update_component) && identifier.update_component
          upd = identifier.update_component.to_s
          identifier_parts << upd
        elsif identifier.respond_to?(:update) && identifier.update
          identifier_parts << "-upd#{identifier.update}"
        end

        # Stage component (ipd, pd, etc.)
        if identifier.respond_to?(:stage) && identifier.stage
          if identifier.stage.respond_to?(:to_s)
          end
          stg = identifier.stage.to_s
          # Stage in MR format starts with dot: ".ipd"
          identifier_parts << stg
        end

        # Supplement (supp, supp-YYYY, suppJan1924-Jan1926, supprev)
        if identifier.respond_to?(:supplement)
          if identifier.supplement_date_range_start && identifier.supplement_date_range_end
            identifier_parts << "supp#{identifier.supplement_date_range_start}-#{identifier.supplement_date_range_end}"
          elsif identifier.respond_to?(:supplement_has_revision) && identifier.supplement_has_revision
            identifier_parts << "supprev"
          elsif identifier.supplement && !identifier.supplement.empty?
            # Smart dash logic from to_s
            supp = identifier.supplement
            identifier_parts << if supp.match?(/^[A-Z]/)
                                  "supp#{supp}"
                                else
                                  "supp-#{supp}"
                                end
          elsif !identifier.supplement
            identifier_parts << "supp"
          end
        end

        # Errata
        if identifier.respond_to?(:errata) && identifier.errata
          identifier_parts << identifier.errata
        end

        # Addendum
        if identifier.respond_to?(:addendum) && (identifier.addendum || identifier.addendum_number)
          identifier_parts << "add."
        end

        # Draft
        if identifier.respond_to?(:draft_number) && identifier.draft_number
          identifier_parts << "#{identifier.draft_number}pd"
        elsif identifier.respond_to?(:draft) && identifier.draft&.to_s&.include?("draft")
          identifier_parts << "-draft"
        end

        # Index, insert, section, appendix
        if identifier.respond_to?(:index) && identifier.index
          identifier_parts << "index"
        end
        if identifier.respond_to?(:insert) && identifier.insert
          identifier_parts << "insert"
        end
        if identifier.respond_to?(:section) && identifier.section
          identifier_parts << "sec#{identifier.section}"
        end
        if identifier.respond_to?(:appendix) && identifier.appendix
          identifier_parts << "app"
        end

        # Join identifier parts with dots (MR format uses dots)
        parts << identifier_parts.join(".") unless identifier_parts.empty?

        # Translation component (separate segment in URN)
        if identifier.respond_to?(:translation_component) && identifier.translation_component
          trans = identifier.translation_component
          lang = if trans.respond_to?(:language)
                   trans.language
                 elsif trans.is_a?(String)
                   trans
                 end
          parts << lang.downcase if lang
        elsif identifier.respond_to?(:translation) && identifier.translation
          parts << identifier.translation.downcase
        end

        parts.join(":")
      end
    end
  end
end
