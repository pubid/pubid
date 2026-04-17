# frozen_string_literal: true

module Pubid
  module Rendering
    module Language
      # Render language codes in parenthetical format
      # @param languages [Array<Components::Language>] language components
      # @param options [Hash] rendering options
      # @return [String] formatted language string
      def render_languages(languages, **options)
        return "" unless languages&.any?

        options[:lang_format] || :short
        formatted = languages.map do |l|
          l.to_s(lang_single: options[:lang_single])
        end
        "(#{formatted.join('/')})"
      end
    end
  end
end
