# frozen_string_literal: true

module PubidNew
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
                  :default_type_abbr, :lang, :lang_single

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
                     lang_single: false)
        @stage_separator = stage_separator
        @stage_separator_with_copublisher = stage_separator_with_copublisher
        @type_separator = type_separator
        @type_separator_with_prefix = type_separator_with_prefix
        @default_type_abbr = default_type_abbr
        @lang = lang
        @lang_single = lang_single
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
    end
  end
end
