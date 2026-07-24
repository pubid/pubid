# frozen_string_literal: true

module Pubid
  module Omg
    # Builds a Pubid::Omg::Identifier from a parse tree.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        Identifiers::Specification.new(
          acronym: data[:acronym].to_s,
          version: data[:version]&.to_s,
        )
      end
    end
  end
end
