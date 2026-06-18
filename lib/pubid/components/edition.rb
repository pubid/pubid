# frozen_string_literal: true

module Pubid
  module Components
    # Edition component (typically a year and number)
    #
    # Human render: "ED#{number}".
    # URN render: "ed-#{number}" per RFC 5141-bis.
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, Lutaml::Model::Type::Value
      attribute :original_text, :string

      def to_s
        number_value = number.is_a?(Components::Code) ? number.value : number
        number_value ? "ED#{number_value}" : nil
      end

      def value
        number.is_a?(Components::Code) ? number.value : number
      end

      def render(context: nil)
        number_value = number.is_a?(Components::Code) ? number.value : number
        return nil unless number_value

        context&.urn? ? "ed-#{number_value}" : "ED#{number_value}"
      end

      def original_format
        original_text
      end
    end
  end
end
