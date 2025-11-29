# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Code component for NIST identifiers
      # Handles number codes like series, part, volume, etc.
      class Code < Lutaml::Model::Serializable
        attribute :number, :string

        def to_s
          number
        end

        # Alias for compatibility
        def value
          number
        end
      end
    end
  end
end