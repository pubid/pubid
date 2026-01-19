# frozen_string_literal: true

module PubidNew
  module Rendering
    # Common rendering methods for identifier string representation
    #
    # This module extracts duplicated rendering logic across flavors
    # to reduce code duplication and ensure consistency.
    #
    # == Usage
    #
    # Include this module in flavor-specific identifier base classes:
    #
    #   class Base < ::PubidNew::Identifier
    #     include PubidNew::Rendering::Common
    #
    #     def to_s(lang: :en, lang_single: false, with_edition: false)
    #       render_identifier(lang: lang, lang_single: lang_single, with_edition: with_edition)
    #     end
    #   end
    #
    module Common
      # Render publisher with optional copublishers
      #
      # @param publisher [Components::Publisher] publisher component
      # @param copublisher_separator [String] separator for copublishers (default: "/")
      # @return [String] formatted publisher string
      def render_publisher(publisher, copublisher_separator: "/")
        return "" unless publisher

        result = publisher.to_s
        if publisher.respond_to?(:copublisher) && publisher.copublisher&.any?
          result += publisher.copublisher.map do |cp|
            "#{copublisher_separator}#{cp}"
          end.join
        end
        result
      end

      # Render stage and type abbreviations with proper separators
      #
      # @param stage [Components::Stage] stage component
      # @param type [Components::Type] type component
      # @param has_copublisher [Boolean] whether identifier has copublisher
      # @param default_type_abbr [String] default type abbreviation to skip (default: "IS")
      # @param stage_separator [String] separator before stage without copublisher
      # @return [String] formatted stage/type string
      def render_stage_type(stage, type, has_copublisher: false,
                           default_type_abbr: "IS",
                           stage_separator: "/")
        result = ""

        # Add stage abbreviation if present
        if stage&.abbr
          sep = has_copublisher ? " " : stage_separator
          result += "#{sep}#{stage.abbr}"
        end

        # Add type abbreviation if present and not default
        if type&.abbr && type.abbr != default_type_abbr
          # Separator: space after stage or copublisher, slash otherwise
          has_prefix = stage&.abbr || has_copublisher
          sep = has_prefix ? " " : stage_separator
          result += "#{sep}#{type.abbr}"
        end

        result
      end

      # Render number with optional parts
      #
      # @param number [Components::Code] primary number component
      # @param part [Components::Code] optional part component
      # @param subpart [Components::Code] optional subpart component
      # @param part_separator [String] separator for parts (default: "-")
      # @return [String] formatted numbering string
      def render_numbering(number, part = nil, subpart = nil,
part_separator: "-")
        return "" unless number&.value

        result = " #{number.value}"
        result += "#{part_separator}#{part.value}" if part&.value
        result += "#{part_separator}#{subpart.value}" if subpart&.value
        result
      end

      # Render stage iteration (e.g., ".1" for stage iteration)
      #
      # @param stage_iteration [Components::Code] stage iteration component
      # @return [String] formatted stage iteration or empty string
      def render_stage_iteration(stage_iteration)
        stage_iteration&.value ? ".#{stage_iteration.value}" : ""
      end

      # Render date with optional year/month/day
      #
      # @param date [Components::Date] date component
      # @param include_month [Boolean] include month in output
      # @param date_separator [String] separator for date parts (default: "-")
      # @return [String] formatted date string or empty string
      def render_date(date, include_month: false, date_separator: "-")
        return "" unless date&.year

        result = ":#{date.year}"
        if date.month && include_month
          result += "#{date_separator}#{format('%02d', date.month)}"
          result += "#{date_separator}#{format('%02d', date.day)}" if date.day
        end
        result
      end

      # Render language codes
      #
      # @param languages [Array<Components::Language>] language components
      # @param lang_single [Boolean] use single character format
      # @param lang_separator [String] separator between languages (default: "/")
      # @return [String] formatted language string or empty string
      def render_languages(languages, lang_single: false, lang_separator: "/")
        return "" unless languages&.any?

        formatted = languages.map do |l|
          l.to_s(lang_single: lang_single)
        end.join(lang_separator)
        "(#{formatted})"
      end

      # Render edition component
      #
      # @param edition [Components::Edition] edition component
      # @param with_prefix [Boolean] include prefix (default: true)
      # @return [String] formatted edition string or empty string
      def render_edition(edition, with_prefix: true)
        return "" unless edition

        if with_prefix
          edition.to_s
        else
          " #{edition}"
        end
      end

      # Check if publisher has copublishers
      #
      # @param publisher [Components::Publisher] publisher component
      # @return [Boolean] true if has copublishers
      def publisher_has_copublisher?(publisher)
        publisher.respond_to?(:has_copublisher?) && publisher.has_copublisher?
      end

      # Get publisher body/name
      #
      # @param publisher [Components::Publisher] publisher component
      # @return [String] publisher body
      def publisher_body(publisher)
        publisher.respond_to?(:body) ? publisher.body : publisher.to_s
      end

      # Get copublishers as array
      #
      # @param publisher [Components::Publisher] publisher component
      # @return [Array<String>] array of copublisher names
      def copublishers_list(publisher)
        return [] unless publisher.respond_to?(:copublisher) && publisher.copublisher&.any?

        publisher.copublisher.map { |cp| publisher_body(cp) }
      end

      # Render full identifier with all components
      #
      # This is a convenience method that combines all rendering methods
      # in the standard order for most identifier types.
      #
      # @param publisher [Components::Publisher] publisher component
      # @param stage [Components::Stage] stage component
      # @param type [Components::Type] type component
      # @param number [Components::Code] number component
      # @param part [Components::Code] part component
      # @param subpart [Components::Code] subpart component
      # @param stage_iteration [Components::Code] stage iteration component
      # @param date [Components::Date] date component
      # @param edition [Components::Edition] edition component
      # @param languages [Array<Components::Language>] language components
      # @param lang [Symbol] language for rendering (:en or :fr)
      # @param lang_single [Boolean] use single char language format
      # @param with_edition [Boolean] include edition in output
      # @param default_type_abbr [String] default type abbreviation to skip
      # @return [String] formatted identifier string
      def render_full_identifier(publisher:, stage: nil, type: nil,
                                 number: nil, part: nil, subpart: nil,
                                 stage_iteration: nil, date: nil,
                                 edition: nil, languages: nil,
                                 lang: :en, lang_single: false,
                                 with_edition: false,
                                 default_type_abbr: "IS")
        result = render_publisher(publisher)
        result += render_stage_type(stage, type,
                                    has_copublisher: publisher_has_copublisher?(
                                      publisher,
                                    ),
                                    default_type_abbr: default_type_abbr)
        result += render_numbering(number, part, subpart)
        result += render_stage_iteration(stage_iteration) if stage_iteration
        result += render_date(date)
        result += render_edition(edition) if with_edition && edition
        result += render_languages(languages, lang_single: lang_single)
        result
      end
    end
  end
end
