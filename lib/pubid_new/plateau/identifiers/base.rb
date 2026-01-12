# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Plateau
    module Identifiers
      # Base class for all PLATEAU identifiers
      class Base < Lutaml::Model::Serializable
        attribute :number, :integer
        attribute :annex, :integer, default: -> {}

        def publisher
          "PLATEAU"
        end

        # Subclasses must implement type_string
        def type_string
          raise NotImplementedError, "Subclasses must implement type_string"
        end

        def formatted_number
          "#%02d" % number
        end

        def formatted_annex
          annex ? "-#{annex}" : ""
        end

        def ==(other)
          return false unless other.class == self.class

          number == other.number &&
            annex == other.annex
        end
      end
    end
  end
end
