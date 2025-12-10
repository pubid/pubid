module PubidNew
  module Components
    # Publication date component
    class Date < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string

      def to_s
        return year.to_s unless month

        result = "#{year}-#{month}"
        result += "-#{day}" if day
        result
      end
    end
  end
end
