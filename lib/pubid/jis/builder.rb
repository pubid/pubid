# frozen_string_literal: true

module Pubid
  module Jis
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Handle supplement case first; the SYMBOL clause (if any) attaches to
        # the outermost identifier, be it the base or the supplement.
        identifier = if data[:amendment]
                       build_amendment(data)
                     elsif data[:explanation]
                       build_explanation(data)
                     elsif data[:corrigendum]
                       build_corrigendum(data)
                     else
                       build_single_identifier(data)
                     end
        attach_symbol(identifier, data)
      end

      private

      # nil => no SYMBOL clause; "" => bare "SYMBOL" keyword; otherwise value.
      def attach_symbol(identifier, data)
        identifier.symbol = data[:symbol_value]&.to_s || "" if data[:symbol_present]
        identifier
      end

      def build_single_identifier(data)
        # Build code component
        code = build_code(data)

        # Extract other attributes
        attrs = {
          code: code,
          year: data[:year]&.to_i,
          language: data[:language]&.to_s,
          all_parts: data[:all_parts] ? true : false,
          reaffirmed: data[:reaffirmed] ? true : false,
        }

        # Determine identifier class from type
        type = data[:type]&.to_s
        klass = case type
                when "TR"
                  Identifiers::TechnicalReport
                when "TS"
                  Identifiers::TechnicalSpecification
                else
                  Identifiers::JapaneseIndustrialStandard
                end

        klass.new(**attrs)
      end

      def build_amendment(data)
        amd_data = data[:amendment]

        # Build base document (without supplement)
        base_data = data.except(:amendment)
        base = build_single_identifier(base_data)

        # Build amendment
        Identifiers::Amendment.new(
          base: base,
          number: amd_data[:amd_number].to_i,
          year: amd_data[:amd_year].to_i,
          reaffirmed: amd_data[:amd_reaffirmed] ? true : false,
        )
      end

      def build_explanation(data)
        expl_data = data[:explanation]

        # Build base document (without supplement)
        base_data = data.except(:explanation)
        base = build_single_identifier(base_data)

        # Build explanation
        Identifiers::Explanation.new(
          base: base,
          number: expl_data[:expl_number]&.to_i,
          year: base.year,
        )
      end

      def build_corrigendum(data)
        corr_data = data[:corrigendum]

        # Build base document (without supplement)
        base_data = data.except(:corrigendum)
        base = build_single_identifier(base_data)

        # Build corrigendum
        Identifiers::Corrigendum.new(
          base: base,
          number: corr_data[:corr_number].to_i,
          year: corr_data[:corr_year].to_i,
          reaffirmed: corr_data[:corr_reaffirmed] ? true : false,
        )
      end

      def build_code(data)
        series = data[:series].to_s
        number_str = data[:number].to_s
        number = number_str.to_i

        # Extract parts with both integer values and original strings
        parts_result = extract_parts(data[:parts])
        parts = parts_result[:parts]
        part_strings = parts_result[:part_strings]

        Components::Code.new(
          series: series,
          number: number,
          parts: parts,
          number_string: number_str,
          part_strings: part_strings,
        )
      end

      def extract_parts(parts_data)
        parts = []
        part_strings = []

        return { parts: parts, part_strings: part_strings } unless parts_data

        # parts_data is an array of hashes with :part key
        if parts_data.is_a?(Array)
          parts_data.each do |part_hash|
            if part_hash[:part]
              part_str = part_hash[:part].to_s
              parts << part_str.to_i
              part_strings << part_str
            end
          end
        elsif parts_data.is_a?(Hash) && parts_data[:part]
          part_str = parts_data[:part].to_s
          parts << part_str.to_i
          part_strings << part_str
        end

        { parts: parts, part_strings: part_strings }
      end
    end
  end
end
