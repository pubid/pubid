# frozen_string_literal: true

require "lutaml/model"
require_relative "identifiers/base"

module PubidNew
  module Plateau
    # Base class for PLATEAU supplements (Annex)
    # Supplements reference a base identifier
    class SupplementIdentifier < Lutaml::Model::Serializable
      attribute :base_identifier, Identifiers::Base
      attribute :letter, :string, default: -> {}

      def publisher
        "PLATEAU"
      end

      # Subclasses must implement supplement_string
      def supplement_string
        raise NotImplementedError, "Subclasses must implement supplement_string"
      end

      def to_s
        "#{base_identifier} #{supplement_string}"
      end

      def ==(other)
        return false unless other.class == self.class

        base_identifier == other.base_identifier &&
          letter == other.letter
      end
    end
  end
end
