# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Components
    # Resource type component (a set of defined resource types)
    class Type < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :abbr, :string
      attribute :type_code, :string
    end
  end
end
