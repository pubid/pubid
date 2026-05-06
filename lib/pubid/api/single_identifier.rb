# frozen_string_literal: true


module Pubid
  module Api
    class SingleIdentifier < Lutaml::Model::Serializable

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
        parts = ["API"]

        # Add type if available
        parts << type_string if methods.include?(:type_string) && type_string

        # Add code/number with part as one token
        parts << code_portion if code_portion

        # Build result - join with space, then add dash+year as one token
        result = parts.join(" ")
        result += "-#{year}" if year
        result += " (R#{reaffirmation})" if reaffirmation
        result
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
