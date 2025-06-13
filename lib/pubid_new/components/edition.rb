module PubidNew
  module Components
    # Edition component (typically a year and number)
    class Edition < Lutaml::Model::Serializable
      attribute :year, :string
      attribute :number, :string
    end
  end
end
