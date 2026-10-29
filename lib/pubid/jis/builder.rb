# frozen_string_literal: true

module Pubid
  module Jis
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Handle supplement case first; the SYMBOL clause (if any) attaches to
        # the outermost identifier, be it the base or the supplement. The
        # bindings bind the supplement's fields flat (amd_type/amd_number/…),
        # so their presence marks the supplement kind.
        identifier = if data[:amd_type]
                       build_amendment(data)
                     elsif data[:expl_type]
                       build_explanation(data)
                     elsif data[:corr_type]
                       build_corrigendum(data)
                     else
                       build_single_identifier(data)
                     end
        attach_symbol(identifier, data)
        # "(all parts)" names every part of the document, so it wraps the
        # document, which holds no mark itself.
        data[:all_parts] ? identifier.to_all_parts : identifier
      end

      private

      # nil => no SYMBOL clause; "" => bare "SYMBOL" keyword; otherwise value.
      def attach_symbol(identifier, data)
        identifier.symbol = data[:symbol_value].to_s if data[:symbol_present]
        identifier
      end

      def build_single_identifier(data)
        attrs = {
          series: data[:series].to_s,
          number: data[:number].to_s,
          parts: extract_part_strings(data[:parts]),
          year: data[:year]&.to_i,
          language: data[:language]&.to_s,
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
        # The bindings carry the supplement's fields at the top level; the
        # base document shares them.
        base = build_single_identifier(data)

        Identifiers::Amendment.new(
          base: base,
          number: data[:amd_number].to_i,
          year: data[:amd_year].to_i,
          reaffirmed: (true if data[:amd_reaffirmed]),
        )
      end

      def build_explanation(data)
        base = build_single_identifier(data)

        Identifiers::Explanation.new(
          base: base,
          number: data[:expl_number]&.to_i,
          year: base.year,
        )
      end

      def build_corrigendum(data)
        base = build_single_identifier(data)

        Identifiers::Corrigendum.new(
          base: base,
          number: data[:corr_number].to_i,
          year: data[:corr_year].to_i,
          reaffirmed: (true if data[:corr_reaffirmed]),
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

Pubid::Jis::Builder.prepend(Pubid::Builder::AllPartsWrap)
