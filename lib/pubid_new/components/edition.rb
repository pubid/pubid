module PubidNew
  module Components
    # Edition component (typically a year and number)
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, :string
      attribute :original_text, :string  # Store the exact parsed edition text
      
      def to_s
        # Use original parsed format if available
        return original_text if original_text
        # Otherwise use canonical format
        number ? "ED#{number}" : nil
      end
    end
  end
end
