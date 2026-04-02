# frozen_string_literal: true

module Pubid
  module Iso
    # Base class for rendering styles using Strategy pattern
    # Each identifier stores its own rendering_style which knows how to render it
    class RenderingStyle
      attr_reader :with_language_code, :stage_format_long, :with_date

      def initialize(with_language_code:, stage_format_long:, with_date:)
        @with_language_code = with_language_code
        @stage_format_long = stage_format_long
        @with_date = with_date
      end

      # Render the identifier according to this style
      # Subclasses should override if needed
      def render(identifier, with_edition: false)
        parts = []

        # Publisher portion
        parts << identifier.publisher_portion(
          lang: :en,
          stage_format_long: stage_format_long,
        )

        # Number portion
        parts << identifier.number_portion(
          lang_single: single_char_language?,
          with_date: with_date,
        )

        # Edition portion (if requested)
        if with_edition && identifier.edition && (identifier.edition.number || identifier.edition.original_text)
          parts << identifier.edition_portion(lang: :en)
        end

        result = parts.compact.join(" ")

        # Language portion (if applicable)
        # CRITICAL: with_edition=true should ALWAYS use multi-char language codes (en, fr, ru, etc.)
        # even if the original parsed format was single-char (E, F, R, etc.)
        if identifier.languages&.any? && with_language_code != :none
          use_single_char = with_edition ? false : single_char_language?
          result << identifier.language_portion(lang_single: use_single_char)
        end

        # All parts notation (if applicable)
        result << " (all parts)" if identifier.respond_to?(:all_parts) && identifier.all_parts

        result
      end

      def single_char_language?
        with_language_code == :single
      end

      def self.from_format(format)
        case format
        when :ref_num_short
          RefNumShort.new
        when :ref_num_long
          RefNumLong.new
        when :ref_dated
          RefDated.new
        when :ref_dated_long
          RefDatedLong.new
        when :ref_undated
          RefUndated.new
        when :ref_undated_long
          RefUndatedLong.new
        else
          RefDatedLong.new # Default
        end
      end
    end

    # Instance reference number: 1-letter language code + short form + dated
    class RefNumShort < RenderingStyle
      def initialize
        super(with_language_code: :single, stage_format_long: false, with_date: true)
      end
    end

    # Instance reference number long: 2-letter language code + long form + dated
    class RefNumLong < RenderingStyle
      def initialize
        super(with_language_code: :iso, stage_format_long: true, with_date: true)
      end
    end

    # Reference dated: no language code + short form + dated
    class RefDated < RenderingStyle
      def initialize
        super(with_language_code: :none, stage_format_long: false, with_date: true)
      end
    end

    # Reference dated long: no language code + short form + dated
    class RefDatedLong < RenderingStyle
      def initialize
        super(with_language_code: :none, stage_format_long: false, with_date: true)
      end
    end

    # Reference undated: no language code + short form + undated
    class RefUndated < RenderingStyle
      def initialize
        super(with_language_code: :none, stage_format_long: false, with_date: false)
      end
    end

    # Reference undated long: no language code + long form + undated
    class RefUndatedLong < RenderingStyle
      def initialize
        super(with_language_code: :none, stage_format_long: true, with_date: false)
      end
    end
  end
end
