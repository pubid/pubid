# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    # CompositeIdentifier is the base class for identifiers that contain
    # collections of other identifiers or package materials.
    #
    # Examples:
    #   - PackageIdentifier: Base + package materials
    #   - Future: BundleIdentifier refactor to use composite
    #
    # This follows the Composite pattern where an identifier can contain
    # other identifiers or additional metadata as a collection.
    class CompositeIdentifier < Lutaml::Model::Serializable
      # The primary/base identifier
      # Use attr_accessor since it can be any identifier object
      attr_accessor :base_identifier

      # Subclasses MUST implement to_s to define how they render
      def to_s
        raise NotImplementedError, "Subclasses must implement to_s method"
      end
    end
  end
end