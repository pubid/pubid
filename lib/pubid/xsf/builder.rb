# frozen_string_literal: true

module Pubid
  module Xsf
    # Builds an identifier object from the Parslet parse tree. XSF has a single
    # concrete type, so the builder always produces an Identifiers::Xep.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        Identifiers::Xep.new(number: data[:number].to_s)
      end
    end
  end
end
