# frozen_string_literal: true

module PubidNew
  module Rendering
    module Supplement
      # Render supplement identifiers (amendment, corrigendum, addendum, etc.)
      # @param base_identifier [Identifier] base identifier
      # @param supplements [Array<Hash>] list of supplements
      # @param options [Hash] rendering options
      # @return [String] formatted supplement string
      def render_supplements(base_identifier, supplements, **options)
        return base_identifier.to_s(**options) unless supplements&.any?

        result = base_identifier.to_s(**options)

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
        abbr = typed_stage&.abbreviation(format_long: options[:stage_format_long]) || type_to_abbr(supp[:type])

        result = "#{sep}#{abbr}"
        result += " #{number}" if number
        result += ":#{date.year}" if date&.year

        result
      end

      def determine_separator(supp, options)
        supp_type = supp[:type]&.to_s
        options[:"#{supp_type}_separator"] || options[:supplement_separator] || "/"
      end

      # Convert supplement type name to abbreviation
      def type_to_abbr(type)
        return "" unless type

        case type.to_s.downcase
        when "amendment" then "Amd"
        when "corrigendum" then "Cor"
        when "addendum" then "Add"
        when "erratum" then "Err"
        else
          type.to_s
        end
      end
    end
  end
end
