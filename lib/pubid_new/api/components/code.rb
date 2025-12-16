# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Api
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          value
        end
      end
    end
  end
end