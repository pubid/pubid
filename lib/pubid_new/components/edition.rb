module PubidNew
  module Components
    # Edition component (typically a year and number)
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, Lutaml::Model::Type::Value # Accept any value type
      attribute :original_text, :string # Store the exact parsed edition text

      def to_s
        # Always use canonical format for rendering
        number_value = number.respond_to?(:value) ? number.value : number
        number_value ? "ED#{number_value}" : nil
      end

      # V1 API compatibility - tests expect .value on edition itself
      def value
        number.respond_to?(:value) ? number.value : number
      end

      # Method to get the original parsed format if needed
      def original_format
        original_text
      end
    end
  end
end
