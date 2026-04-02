# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          value.to_s
        end
      end
    end
  end
end
