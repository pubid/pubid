# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Components
    # Stage component (a set of defined stages)
    class Stage < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :stage_code, :string
      attribute :harmonized_stages, :string, collection: true
      attribute :abbr, :string
    end
  end
end
