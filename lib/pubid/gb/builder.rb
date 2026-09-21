# frozen_string_literal: true

module Pubid
  module Gb
    # Builds a Pubid::Gb::Identifier from a parse tree.
    #
    # The parser captures the publisher code verbatim (which may already
    # include the "/T" or "/Z" suffix). The builder normalizes: if the
    # suffix is in the code, it is split out into the separate +mandate+
    # attribute so the renderer can recompose either the inline or split
    # form. The code itself goes into the inherited +publisher+ component.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        code, mandate = split_mandate(data[:publisher_code].to_s)

        identifier = Identifiers::Standard.new(
          publisher: ::Pubid::Components::Publisher.new(body: code),
          mandate: mandate || data[:mandate]&.to_s,
          number: data[:number].to_s,
          part: data[:part]&.to_s,
          date: date_for(data[:year]),
        )

        # "(all parts)" names every part of the document, so it wraps the
        # document, which holds no mark itself.
        data[:all_parts].to_s.empty? ? identifier : identifier.to_all_parts
      end

      private

      # The publication year, or nil for a partial reference.
      def date_for(year)
        return nil unless year

        ::Pubid::Components::Date.new(year: year.to_s)
      end

      # If the publisher code carries an inline /T or /Z suffix, split it off
      # and return the cleaned code + extracted mandate.
      def split_mandate(code)
        if code =~ %r{\A(.*?)/(T|Z)\z}
          [Regexp.last_match(1), Regexp.last_match(2)]
        else
          [code, nil]
        end
      end
    end
  end
end
