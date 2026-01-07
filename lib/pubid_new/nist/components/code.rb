# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Code component for NIST identifiers
      # Handles number codes like series, volume, etc.
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :subpart, :string

        def to_s
          result = number.to_s
          result += ".#{subpart}" if subpart
          result
        end

        # Alias for compatibility
        def value
          to_s
        end
      end
    end
  end
end