# frozen_string_literal: true

module Pubid
  module Nist
    # Parser class for NIST identifiers
    # Single Responsibility: Parsing NIST identifier syntax
    class Parser
      # The bound hash passes engine nodes through for the (raw) wrapper
      # bindings: Parsanol::Slice spans, single-element repetition arrays,
      # and named-node hashes. The Parslet tree gave the caster plain
      # strings and hashes of strings; this restores that shape.
      def self.normalize_bound(value)
        case value
        when Parsanol::Slice then value.to_s
        when Hash then value.transform_values { |v| normalize_bound(v) }
        when Array
          inner = value.map { |v| normalize_bound(v) }
          inner.length == 1 ? inner.first : inner
        else value
        end
      end

      # Class-level parse method with preprocessing.
      # Delegates all string normalization to Nist::Preprocessor, then
      # feeds the cleaned string to the parg backend and stamps the
      # detected format onto the parse tree.
      def self.class_parse_with_preprocessing(input)
        # The shared Grammar strips a trailing "(all parts)", but the NIST
        # preprocessor runs first and would swallow it — strip before it and
        # carry the marker to the tree like Grammar#parse does.
        all_parts = input.is_a?(String) && input.match?(::Pubid::Parser::ALL_PARTS_SUFFIX)
        input = input.sub(::Pubid::Parser::ALL_PARTS_SUFFIX, "") if all_parts
        result = Preprocessor.new(input).call
        parsed = normalize_bound(Pubid::Parg::Model.bound(:nist, result.cleaned))
        if all_parts
          parsed = case parsed
                   when Hash then parsed.merge(all_parts: true)
                   when Array then parsed.map { |h| h.merge(all_parts: true) }
                   else parsed
                   end
        end

        if parsed.is_a?(Hash)
          parsed.merge(parsed_format: result.format)
        elsif parsed.is_a?(Array)
          merged = parsed.each_with_object({}) do |hash, acc|
            next acc unless hash.is_a?(Hash)

            acc.merge!(hash)
          end
          merged.merge(parsed_format: result.format)
        else
          parsed
        end
      end
    end
  end
end
