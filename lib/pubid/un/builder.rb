# frozen_string_literal: true

module Pubid
  module Un
    class Builder
      YEAR_REGEX = /\A\d{4}\z/.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        tokens = extract_tokens(data)
        raise "UN identifier has no tokens" if tokens.empty?

        number = tokens.last
        path = tokens[0...-1]
        year_token = path.reverse.find { |t| t.match?(YEAR_REGEX) }

        Identifiers::Document.new(
          path: path,
          number: number,
          date: year_token ? ::Pubid::Components::Date.new(year: year_token) : nil,
        )
      end

      private

      def extract_tokens(data)
        raw = data.is_a?(Hash) ? data[:token] : data
        case raw
        when Array
          raw.map { |h| h.is_a?(Hash) ? h[:token].to_s : h.to_s }
        when Hash
          [raw[:token].to_s]
        else
          [raw.to_s]
        end
      end
    end
  end
end
