module PubidNew
  module Components
    # Edition component (typically a year and number)
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, :string
      attribute :original_text, :string  # Store the exact parsed edition text

      def to_s
        # Always use canonical format for rendering
        number ? "ED#{number}" : nil
      end

      # Method to get the original parsed format if needed
      def original_format
        original_text
      end
    end
  end
end
