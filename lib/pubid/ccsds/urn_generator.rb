# frozen_string_literal: true

module Pubid
  module Ccsds
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        if identifier.is_a?(SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      protected

      def generate_base_urn
        parts = ["urn", "ccsds"]

        identifier_parts = []

        series = maybe(:series)
        if series
          s = series.to_s
          identifier_parts << s if s && !s.empty?
        end

        if identifier.number
          number = identifier.number.to_s
          identifier_parts << number if number && !number.empty?
        end

        part = maybe(:part)
        if part
          p = part.to_s
          identifier_parts << ".#{p}" if p && !p.empty?
        end

        book_color = maybe(:book_color)
        if book_color
          bc = book_color.to_s
          identifier_parts << "-#{bc}" if bc && !bc.empty?
        elsif identifier.type
          t = identifier.type.to_s
          identifier_parts << "-#{t}" if t && !t.empty?
        end

        edition = maybe(:edition)
        if edition
          e = if edition.is_a?(Pubid::Components::Edition)
                edition.number || edition.value
              else
                edition.to_s
              end
          identifier_parts << "-#{e}" if e && !e.to_s.empty?
        end

        retired = maybe(:retired)
        if retired
          identifier_parts << "-S"
        else
          suffix = maybe(:suffix)
          if suffix
            s = suffix.to_s
            identifier_parts << "-#{s}" if s && !s.empty?
          end
        end

        parts << identifier_parts.join unless identifier_parts.empty?

        language = maybe(:language)
        if language
          lang_code = if language&.code
                        language.code
                      elsif language.is_a?(String)
                        language
                      else
                        language.to_s
                      end
          lang_code = lang_code.gsub(/ Translated$/, "").downcase if lang_code
          parts << lang_code if lang_code && !lang_code.empty?
        end

        parts.join(":")
      end

      def generate_supplement_urn
        parts = ["urn", "ccsds"]

        current = identifier
        supplement_chain = []

        while current.is_a?(SupplementIdentifier)
          supplement_chain.unshift(current)
          current = current.base_identifier
        end

        base_gen = self.class.new(current)
        base_urn = base_gen.generate_base_urn

        base_identifier_part = base_urn.sub(/^urn:ccsds:/, "")
        parts << base_identifier_part

        supplement_chain.each do |supp|
          if supp.number&.value
            parts << "cor.#{supp.number.value}"
          elsif supp.typed_stage
            parts << supp.typed_stage.type_code.to_s
          end
        end

        parts.join(":")
      end
    end
  end
end
