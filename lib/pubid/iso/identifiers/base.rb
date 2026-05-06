# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    module Identifiers
      # Base class for ISO identifiers
      class Base < ::Pubid::Identifier
        # Inherit most attributes from parent
        # ISO-specific attributes
        attribute :stage_iteration, ::Pubid::Iso::Components::Code

        # ISO rendering context singleton
        def self.rendering_context
          @rendering_context ||= Pubid::Rendering::RenderingContext.iso
        end

        # Render identifier using OOP approach - each component renders itself
        #
        # @param lang [Symbol] language for rendering (:en or :fr)
        # @param lang_single [Boolean] use single char language format
        # @param with_edition [Boolean] include edition in output
        # @return [String] formatted identifier string
        def to_s(lang: :en, lang_single: false, with_edition: false)
          # Create rendering context with language settings
          context = Pubid::Rendering::RenderingContext.new(
            stage_separator: "/",
            stage_separator_with_copublisher: " ",
            type_separator: "/",
            type_separator_with_prefix: " ",
            default_type_abbr: "IS",
            lang: lang,
            lang_single: lang_single,
          )

          # Compose the identifier from component renderings
          render_from_components(context: context, with_edition: with_edition)
        end

        private

        # Compose identifier string by having each component render itself
        #
        # @param context [RenderingContext] rendering context for flavor rules
        # @param with_edition [Boolean] include edition in output
        # @return [String] composed identifier string
        def render_from_components(context:, with_edition: false)
          parts = []
          parts << publisher.to_s

          # Stage renders itself with context-aware separators
          if stage
            has_copub = publisher&.has_copublisher?
            parts << stage.to_s(context: context, has_copublisher: has_copub)
          end

          # Type renders itself with context-aware separators and default handling
          if type
            has_prefix = stage || publisher&.has_copublisher?
            type_render = type.to_s(context: context, has_prefix: has_prefix)
            parts << type_render if type_render != ""
          end

          # Number renders itself
          parts << " #{number.value}" if number&.value

          # Parts render themselves
          parts << "-#{part.value}" if part&.value
          parts << "-#{subpart.value}" if subpart&.value

          # Stage iteration renders itself
          parts << ".#{stage_iteration.value}" if stage_iteration&.value

          # Date renders itself with context
          parts << date.to_s(context: context) if date&.year

          # Edition renders itself
          parts << " #{edition}" if with_edition && edition&.number

          # Languages render themselves
          if languages&.any?
            parts << "(#{languages.map do |l|
              l.to_s(lang_single: context.lang_single)
            end.join('/')})"
          end

          parts.join
        end

        public

        # V1 API compatibility - tests expect .copublishers returning array of Publisher objects
        def copublishers
          return [] unless publisher.copublisher&.any?

          publisher.copublisher.map do |cp|
            ::Pubid::Components::Publisher.new(body: cp)
          end
        end

        def ==(other)
          return false unless other.is_a?(Base)

          publisher == other.publisher &&
            type == other.type &&
            number == other.number &&
            part == other.part &&
            date == other.date &&
            stage == other.stage
        end
      end
    end
  end
end
