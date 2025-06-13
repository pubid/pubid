module PubidNew
  module Components
    # Publication date component
    class Date < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :month, :string
      attribute :day, :string
    end
  end
end
