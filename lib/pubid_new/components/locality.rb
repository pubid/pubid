# frozen_string_literal: true
module PubidNew
  module Components
    # Handles "all parts"
    class Locality < Lutaml::Model::Serializable
      attribute :value, :string
    end
  end
end
