# frozen_string_literal: true

module Pubid
  module Rendering
    module Supplement
      # Render supplement identifiers (amendment, corrigendum, addendum, etc.)
      # @param base [Identifier] base identifier
      # @param supplements [Array<Hash>] list of supplements
      # @param options [Hash] rendering options
      # @return [String] formatted supplement string
      def render_supplements(base, supplements, **options)
        return base.to_s(**options) unless supplements&.any?

        result = base.to_s(**options)

        supplements.each do |supp|
          result += render_single_supplement(supp, **options)
        end

        result
      end

      private

      def render_single_supplement(supp, **options)
        typed_stage = supp[:typed_stage]
        number = supp[:number]
        date = supp[:date]

        sep = determine_separator(supp, options)
        abbr = typed_stage.abbreviation(format_long: options[:stage_format_long])

        result = "#{sep}#{abbr}"
        result += " #{number}" if number
        result += ":#{date.year}" if date&.year

        result
      end

      def determine_separator(supp, options)
        supp_type = supp[:type]&.to_s
        options[:"#{supp_type}_separator"] || options[:supplement_separator] || "/"
      end
    end
  end
end
