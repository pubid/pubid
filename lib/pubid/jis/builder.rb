# frozen_string_literal: true

module Pubid
  module Jis
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = flatten_supplement(data)
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

      SUPPLEMENT_KEYS = %i[amendment explanation corrigendum].freeze

      # The typed bindings carry a supplement's fields flat (amd_type, …).
      # The raw parse tree nests them under :amendment, :explanation or
      # :corrigendum. Read both shapes, or the tree path drops the
      # supplement.
      def flatten_supplement(data)
        key = SUPPLEMENT_KEYS.find { |k| data[k].is_a?(Hash) }
        return data unless key

        data.except(key).merge(data[key].compact)
      end

      # nil => no SYMBOL clause; "" => bare "SYMBOL" keyword; otherwise value.
      def attach_symbol(identifier, data)
        identifier.symbol = data[:symbol_value].to_s if data[:symbol_present]
        identifier
      end

      def build_single_identifier(data)
        attrs = {
          number: data[:number].to_s,
          parts: extract_part_strings(data[:parts]),
          year: data[:year]&.to_i,
          language: data[:language]&.to_s,
          reaffirmed: (true if data[:reaffirmed]),
        }
        # A WES id carries no series letter, so its series stays nil.
        return build_wes(data, attrs) if data[:wes]

        jis_class_for_type(data[:type]&.to_s)
          .new(series: data[:series].to_s, **attrs)
      end

      # `wes_type` ("TR"/"TS") picks the WES class. `wes_language` is a
      # language printed before the year ("WES 1112(E):2022").
      def build_wes(data, attrs)
        attrs = attrs.merge(wes_language_attrs(data)) if data[:wes_language]
        Identifiers::WeldingEngineeringStandard
          .class_for_type(data[:wes_type]&.to_s).new(**attrs)
      end

      def wes_language_attrs(data)
        if data[:language]
          raise Pubid::Errors::ParseError.new(
            "a WES id carries one language, not two", nil
          )
        end

        { language: data[:wes_language].to_s, language_before_year: true }
      end

      def jis_class_for_type(type)
        case type
        when "TR" then Identifiers::TechnicalReport
        when "TS" then Identifiers::TechnicalSpecification
        else Identifiers::JapaneseIndustrialStandard
        end
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
