# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Directives < SingleIdentifier
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.type[:key] }
        attribute :subgroup, ::Pubid::Components::Code

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :dir,
            abbr: ["DIR", "Directives Part", "Directives, Part", "Directives,",
                   "Directives"],
            short_abbr: "DIR",
            long_abbr: "Directives, Part",
            name: "Directives",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dir, title: "Directives", short: "DIR" }
        end

        def publisher_portion(lang: :en, stage_format_long: true,
with_language_code: :none, with_date: true)
          abbr = typed_stage ? typed_stage.abbreviation(format_long: stage_format_long) : ""

          unless copublishers&.any?
            return [
              publisher.body,
              (subgroup ? " #{subgroup.value}" : ""),
              (abbr.empty? ? "" : " #{abbr}"),
            ].join
          end

          # If there are copublishers, join them with slashes
          [
            ([publisher] + copublishers).map(&:body).join("/"),
            (subgroup ? " #{subgroup.value}" : ""),
            (abbr.empty? ? "" : " #{abbr}"),
          ].join
        end

        # This differs from the basic number_portion in that directives may have
        # a variant (ISO or IEC) after the number rendered as a part but
        # separated by a space.
        def number_portion(lang_single: false, with_date: true)
          result = [
            # Directives may not have a number
            (number ? number.value.to_s : ""),

            # Parts and subparts are optional
            (part ? " #{part.value}" : ""),
            (subpart ? "-#{subpart.value}" : ""),

            # Stage iteration is optional
            (stage_iteration ? ".#{stage_iteration.value}" : ""),

            # Date is optional - but don't add leading space if result is empty
            (date && with_date ? ":#{date.year}" : ""),
          ].join.strip # Strip to remove any leading/trailing spaces

          # Return nil if there's nothing to render
          result.empty? ? nil : result
        end

        # Directives use a different URN scheme: urn:iso:doc instead of urn:iso:std
        # Format: urn:iso:doc:{publisher}[:{subgroup}][:{subgroup_number}]:dir[:{number}][:{part}][:{year}]
        def to_urn
          parts = ["urn", "iso", "doc"]

          # Publisher (lowercase, hyphen-separated)
          copubs = copublishers || []
          parts << ([publisher] + copubs).map(&:body).map(&:downcase).join("-")

          # Subgroup (e.g., JTC) and its number if present
          if subgroup
            # Split subgroup like "JTC 1" into "jtc" and "1"
            subgroup_parts = subgroup.value.split
            parts << subgroup_parts[0].downcase if subgroup_parts[0]
            parts << subgroup_parts[1] if subgroup_parts[1]
          end

          # Type is always 'dir' for Directives
          parts << "dir"

          # Number (optional for Directives, but comes after dir type)
          parts << number.value if number

          # Part (organization variant like ISO or IEC, lowercase)
          parts << part.value.downcase if part

          # Year (if present)
          parts << date.year if date

          parts.join(":")
        end

        def to_s(lang: :en, lang_single: false, with_edition: false,
format: nil, stage_format_long: nil, with_date: nil)
          # Handle format parameter if provided
          if format
            super
          elsif stage_format_long || with_date || lang_single
            super
          elsif rendering_style
            # Use rendering_style but handle special DIR cases
            parts = []

            # Publisher portion (includes JTC subgroup and DIR type)
            parts << publisher_portion(
              lang: lang,
              stage_format_long: false, # Always use short form "DIR" for normalization
            )

            # Number portion (may be just ":date" if no number)
            num_part = number_portion(
              lang_single: rendering_style.single_char_language?,
              with_date: rendering_style.with_date,
            )

            # If number portion starts with ":" (just date, no number), don't add space
            if num_part&.start_with?(":")
              result = parts.compact.join(" ") + num_part
            else
              parts << num_part if num_part
              result = parts.compact.join(" ")
            end

            # Edition portion (if requested)
            if with_edition && edition && (edition.number || edition.original_text)
              result << " " << edition_portion(lang: lang).to_s
            end

            # Language portion (if applicable)
            if languages&.any? && rendering_style.with_language_code != :none
              result << language_portion(lang_single: rendering_style.single_char_language?)
            end

            result
          else
            # Always normalize to short form "DIR" for consistency
            parts = []

            # Publisher portion (includes JTC subgroup and DIR type)
            parts << publisher_portion(
              lang: lang,
              stage_format_long: false, # Always use short form "DIR"
            )

            # Number portion (may be just ":date" if no number)
            num_part = number_portion(
              lang_single: lang_single,
              with_date: true,
            )

            # If number portion starts with ":" (just date, no number), don't add space
            if num_part&.start_with?(":")
              result = parts.compact.join(" ") + num_part
            else
              parts << num_part if num_part
              result = parts.compact.join(" ")
            end

            # Edition portion (if requested)
            if with_edition && edition && (edition.number || edition.original_text)
              result << " " << edition_portion(lang: lang).to_s
            end

            # Language portion (if applicable)
            if languages&.any?
              result << language_portion(lang_single: lang_single)
            end

            result
          end
        end
      end
    end
  end
end
