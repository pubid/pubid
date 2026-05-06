# frozen_string_literal: true

module Pubid
  module Components
    # Edition component (typically a year and number)
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, Lutaml::Model::Type::Value # Accept any value type
      attribute :original_text, :string # Store the exact parsed edition text

      def to_s
        # Always use canonical format for rendering
        number_value = number.is_a?(Components::Code) ? number.value : number
        number_value ? "ED#{number_value}" : nil
      end

      # V1 API compatibility - tests expect .value on edition itself
      def value
        number.is_a?(Components::Code) ? number.value : number
      end

      def render(context: nil)
        to_s
      end

      # Method to get the original parsed format if needed
      def original_format
        original_text
      end
    end
  end
end
