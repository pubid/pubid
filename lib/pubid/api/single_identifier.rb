# frozen_string_literal: true

module Pubid
  module Api
    class SingleIdentifier < Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation

      # Stored as a plain string (always "API") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute.
      attribute :publisher, :string, default: -> { "API" }

      attribute :code, Components::Code
      attribute :part, :string
      attribute :year, :string
      attribute :reaffirmation, :string

      def to_s
        render(format: :human)
      end

      private

      def code_portion
        return nil unless code

        code_str = code.to_s
        code_str += "-#{part}" if part
        code_str
      end
    end
  end
end
