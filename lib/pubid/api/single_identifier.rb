# frozen_string_literal: true

module Pubid
  module Api
    class SingleIdentifier < Pubid::Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def publisher
        "API"
      end

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
