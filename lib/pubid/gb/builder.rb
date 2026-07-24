# frozen_string_literal: true

module Pubid
  module Gb
    # Builds a Pubid::Gb::Identifier from a parse tree.
    #
    # The parser captures the publisher code verbatim (which may already
    # include the "/T" or "/Z" suffix). The builder normalizes: if the
    # suffix is in the publisher_code string, it's split out into the
    # separate +mandate+ attribute so the renderer can recompose either
    # the inline or split form.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        publisher_code, mandate = split_mandate(data[:publisher_code].to_s)

        mandate ||= data[:mandate]&.to_s

        Identifiers::Standard.new(
          publisher_code: publisher_code,
          mandate: mandate,
          number: data[:number].to_s,
          part: data[:part]&.to_s,
          date: data[:year] ? ::Pubid::Components::Date.new(year: data[:year].to_s) : nil,
          all_parts: !data[:all_parts].to_s.empty?,
        )
      end

      private

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
