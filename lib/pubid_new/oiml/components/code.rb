# frozen_string_literal: true

module PubidNew
  module Oiml
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :part, :string
        attribute :subpart, :string

        def to_s
          result = number.to_s
          result += "-#{part}" if part
          result += "-#{subpart}" if subpart
          result
        end
      end
    end
  end
end