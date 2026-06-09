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
          all_parts: (true if data[:all_parts]),
          reaffirmed: (true if data[:reaffirmed]),
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
          reaffirmed: (true if amd_data[:amd_reaffirmed]),
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
          reaffirmed: (true if corr_data[:corr_reaffirmed]),
        )
      end

      def build_code(data)
        Components::Code.new(
          series: data[:series].to_s,
          number: data[:number].to_s,
          parts: extract_part_strings(data[:parts]),
        )
      end

      # parts_data is an array of `{ part: "1" }` hashes (or a single hash for
      # a one-level part); return the part numbers as strings.
      def extract_part_strings(parts_data)
        case parts_data
        when Array then parts_data.filter_map { |h| h[:part]&.to_s }
        when Hash then [parts_data[:part]&.to_s].compact
        else []
        end
      end
    end
  end
end
