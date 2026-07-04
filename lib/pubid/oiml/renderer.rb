# frozen_string_literal: true

module Pubid
  module Oiml
    # Human-readable renderer for OIML identifiers.
    #
    # Produces strings like:
    #   "OIML R 60:2000"
    #   "OIML R 60 Edition 2013"
    #   "OIML R 60 Annex A Edition 2013 (E)"
    #   "OIML R 60 Annexes:2021 (E)"
    #
    # The renderer is registered as the `:human` format in the OIML format
    # registry and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id
        @context = context

        case id
        when Identifiers::Annex
          render_annex(id)
        when SupplementIdentifier
          render_supplement(id)
        when SingleIdentifier
          render_single(id)
        else
          id.to_s
        end
      end

      private

      def effective_format(id)
        id.requested_format ||
          (id.parsed_format == "long" ? :long : :short)
      end

      # Strip a trailing language group "(...)" from a rendered base string so
      # the supplement can re-attach its own language at the end.
      def strip_language(str)
        str.sub(/\s*\([^)]+\)\s*$/, "").strip
      end

      def render_single(id)
        format = effective_format(id)

        result = "#{id.publisher} #{id.type_string} #{id.code}"

        using_edition_format = false

        if id.edition && id.date
          result += " #{id.edition} Edition #{id.date.render(context: @context)}"
          using_edition_format = true
        elsif id.edition
          result += " #{id.edition}"
          using_edition_format = true
        elsif id.date
          if format == :long
            result += " Edition #{id.date.render(context: @context)}"
            using_edition_format = true
          else
            result += ":#{id.date.render(context: @context)}"
          end
        end

        if id.stage || id.iteration
          result += " "
          result += id.iteration.to_s if id.iteration
          result += id.stage.to_s if id.stage
        end

        if id.language
          result += if using_edition_format || id.parsed_format == "short_with_space"
                      " (#{id.language})"
                    else
                      "(#{id.language})"
                    end
        end

        result
      end

      def render_supplement(id)
        format = effective_format(id)

        # Plus-joined: "BASE+Amendment:YEAR" / "BASE+Errata:YEAR" with both
        # the base and the supplement carrying their own year.
        if id.joined
          base_str = strip_language(id.base_identifier.to_s)
          result = "#{base_str}+#{id.supplement_type}"
          result += ":#{id.year}" if id.year
          result += " (#{id.language})" if id.language
          return result
        end

        # Trailing-word shorthand: "BASE Amendment" / "BASE Errata" with the
        # publication year kept on the base identifier. The word comes from the
        # concrete supplement class.
        if id.trailing
          base_str = strip_language(id.base_identifier.to_s)
          result = "#{base_str} #{id.supplement_type}"
          result += " (#{id.language})" if id.language
          return result
        end

        base_format = if format && format != :short
                        format
                      elsif id.base_identifier.class.attributes.key?(:parsed_format) && id.base_identifier.parsed_format == "long"
                        :long
                      else
                        :short
                      end

        base_str = if id.base_identifier.is_a?(SingleIdentifier)
                     id.base_identifier.to_s(format: base_format)
                   else
                     id.base_identifier.to_s
                   end
        base_str = strip_language(base_str)

        result = "#{id.supplement_type} (#{id.year}) to #{base_str}"
        result += " (#{id.language})" if id.language

        result
      end

      def render_annex(id)
        format = effective_format(id)

        # "BASE:YYYY Annex(es)" — the year is glued to the base, the marker
        # carries none. Keep the base date instead of stripping it.
        if id.year_on_base
          base_str = strip_language(id.base_identifier.to_s)
          marker = id.letter ? "Annex #{id.letter}" : "Annexes"
          result = "#{base_str} #{marker}"
          result += " (#{id.language})" if id.language
          return result
        end

        base_format = if id.base_identifier.class.attributes.key?(:parsed_format) && id.base_identifier.parsed_format == "long"
                        :long
                      else
                        :short
                      end

        annex_format = if format
                         format
                       elsif id.class.attributes.key?(:parsed_format) && id.parsed_format == "long"
                         :long
                       else
                         :short
                       end

        base_str = if id.base_identifier.is_a?(SingleIdentifier)
                     id.base_identifier.to_s(format: base_format)
                   else
                     id.base_identifier.to_s
                   end
        result = base_str.sub(/:.*/, "").sub(/\s+Edition\s+\d{4}/, "").sub(
          /\(.*\)/, ""
        ).strip

        if id.letter
          result += " Annex #{id.letter}"
          result += " Edition #{id.year}" if id.year
        else
          result += " Annexes"
          if id.year
            result += annex_format == :long ? " Edition #{id.year}" : ":#{id.year}"
          elsif id.base_identifier.date
            result += annex_format == :long ? " Edition #{id.base_identifier.date.render(context: @context)}" : ":#{id.base_identifier.date.render(context: @context)}"
          end
        end

        result += " (#{id.language})" if id.language
        result
      end
    end
  end
end
