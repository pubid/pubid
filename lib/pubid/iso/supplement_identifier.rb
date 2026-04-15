# frozen_string_literal: true

module Pubid
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :separator, ::Lutaml::Model::Type::String

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end

      def to_s(lang: :en, lang_single: false, with_edition: false, format: nil,
stage_format_long: nil, with_date: nil)
        # If format is provided, create appropriate rendering style
        if format
          style = RenderingStyle.from_format(format)
          lang_single = style.single_char_language?
          stage_format_long = style.stage_format_long
          with_date = style.with_date
        elsif stage_format_long.nil? && with_date.nil?
          # Use stored rendering_style settings
          # CRITICAL: with_edition=true should ALWAYS use multi-char language codes
          lang_single = with_edition ? false : rendering_style.single_char_language?
          stage_format_long = rendering_style.stage_format_long
          with_date = rendering_style.with_date
        else
          # Use provided parameters or defaults
          # CRITICAL: with_edition=true should ALWAYS use multi-char language codes
          lang_single = with_edition ? false : (lang_single || rendering_style&.single_char_language? || false)
          stage_format_long = false if stage_format_long.nil?
          with_date = true if with_date.nil?
        end

        sep = separator && !separator.empty? ? separator : "/"

        [].tap do |parts|
          parts << [
            base_identifier.to_s(
              lang: lang,
              lang_single: lang_single,
              with_edition: with_edition,
              format: format,
              stage_format_long: stage_format_long,
              with_date: with_date,
            ),
            "#{sep}#{typed_stage.abbreviation(format_long: stage_format_long)}",
          ].join
          # Only add space if number_portion has a number (not just a date starting with :)
          num_port = number_portion(lang_single: lang_single)
          if num_port && !num_port.empty? && !num_port.start_with?(":")
            parts << (typed_stage.abbreviation(format_long: stage_format_long).end_with?(".") ? "" : " ")
          end
          parts << num_port

          parts << " #{edition_portion(lang: lang)}" if with_edition && edition&.number
          parts << language_portion(lang_single: lang_single) if languages&.any?
        end.compact.join
      end

      # Generate URN for supplement using UrnGenerator
      # Inherits from SingleIdentifier but supplements have special URN format
      #
      # @return [String] The generated URN in RFC 5141-bis format
      def to_urn
        require_relative "urn_generator"
        UrnGenerator.new(self).generate
      end
    end
  end
end
