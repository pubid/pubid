# frozen_string_literal: true

module PubidNew
  module Rendering
    module Language
      # Render language codes in parenthetical format
      # @param languages [Array<Components::Language>] language components
      # @param options [Hash] rendering options
      # @return [String] formatted language string
      def render_languages(languages, **options)
        return "" unless languages&.any?

        format = options[:lang_format] || :short
        formatted = languages.map { |l| l.to_s(lang_single: options[:lang_single]) }
        "(#{formatted.join('/')})"
      end
    end
  end
end
