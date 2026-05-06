# frozen_string_literal: true

module Pubid
  module Rendering
    # Context object for flavor-specific rendering rules
    #
    # This encapsulates the rendering rules that vary between flavors,
    # allowing components to render themselves correctly based on context.
    #
    # == Usage
    #
    #   context = RenderingContext.new(
    #     stage_separator: "/",
    #     stage_separator_with_copublisher: " ",
    #     type_separator: "/",
    #     type_separator_with_prefix: " ",
    #     default_type_abbr: "IS"
    #   )
    #   identifier.to_s(context: context)
    #
    class RenderingContext
      attr_reader :stage_separator, :stage_separator_with_copublisher,
                  :type_separator, :type_separator_with_prefix,
                  :default_type_abbr, :lang, :lang_single,
                  :with_language_code, :stage_format_long, :with_date

      # Initialize a new rendering context
      #
      # @param stage_separator [String] separator before stage without copublisher
      # @param stage_separator_with_copublisher [String] separator before stage with copublisher
      # @param type_separator [String] separator before type (default)
      # @param type_separator_with_prefix [String] separator before type when prefix exists
      # @param default_type_abbr [String] default type abbreviation to skip rendering
      # @param lang [Symbol] language for rendering (:en or :fr)
      # @param lang_single [Boolean] use single char language format
      def initialize(stage_separator: "/",
                     stage_separator_with_copublisher: " ",
                     type_separator: "/",
                     type_separator_with_prefix: " ",
                     default_type_abbr: "IS",
                     lang: :en,
                     lang_single: false,
                     with_language_code: :none,
                     stage_format_long: false,
                     with_date: true)
        @stage_separator = stage_separator
        @stage_separator_with_copublisher = stage_separator_with_copublisher
        @type_separator = type_separator
        @type_separator_with_prefix = type_separator_with_prefix
        @default_type_abbr = default_type_abbr
        @lang = lang
        @lang_single = lang_single
        @with_language_code = with_language_code
        @stage_format_long = stage_format_long
        @with_date = with_date
      end

      # Get the appropriate stage separator based on whether there's a copublisher
      #
      # @param has_copublisher [Boolean] whether identifier has copublisher
      # @return [String] the separator to use
      def stage_separator_for(has_copublisher:)
        has_copublisher ? @stage_separator_with_copublisher : @stage_separator
      end

      # Get the appropriate type separator based on whether there's a prefix
      #
      # @param has_prefix [Boolean] whether there's a prefix (stage or copublisher)
      # @return [String] the separator to use
      def type_separator_for(has_prefix:)
        has_prefix ? @type_separator_with_prefix : @type_separator
      end

      # Check if type should be rendered (not default)
      #
      # @param type_abbr [String] type abbreviation to check
      # @return [Boolean] true if type should be rendered
      def should_render_type?(type_abbr)
        type_abbr && type_abbr != @default_type_abbr
      end

      # ISO rendering context singleton
      # @return [RenderingContext] ISO-specific context
      def self.iso
        @iso ||= new(
          stage_separator: "/",
          stage_separator_with_copublisher: " ",
          type_separator: "/",
          type_separator_with_prefix: " ",
          default_type_abbr: "IS",
        )
      end

      # IEC rendering context singleton
      # @return [RenderingContext] IEC-specific context
      def self.iec
        @iec ||= new(
          stage_separator: "/",
          stage_separator_with_copublisher: " ",
          type_separator: "/",
          type_separator_with_prefix: " ",
          default_type_abbr: "IS",
        )
      end

      # NIST rendering context singleton
      # @return [RenderingContext] NIST-specific context
      def self.nist
        @nist ||= new(
          stage_separator: "",
          stage_separator_with_copublisher: " ",
          type_separator: " ",
          type_separator_with_prefix: " ",
          default_type_abbr: "",
        )
      end

      # Format factory methods — replace RenderingStyle hierarchy
      def self.ref_num_short
        new(with_language_code: :single, stage_format_long: false, with_date: true)
      end

      def self.ref_num_long
        new(with_language_code: :iso, stage_format_long: true, with_date: true)
      end

      def self.ref_dated
        new(with_language_code: :none, stage_format_long: false, with_date: true)
      end

      def self.ref_undated
        new(with_language_code: :none, stage_format_long: false, with_date: false)
      end

      def self.ref_undated_long
        new(with_language_code: :none, stage_format_long: true, with_date: false)
      end

      def self.from_format(format)
        case format
        when :ref_num_short then ref_num_short
        when :ref_num_long then ref_num_long
        when :ref_dated then ref_dated
        when :ref_dated_long then ref_dated
        when :ref_undated then ref_undated
        when :ref_undated_long then ref_undated_long
        else ref_dated
        end
      end
    end
  end
end
