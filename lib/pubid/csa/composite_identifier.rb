# frozen_string_literal: true

require "lutaml/model"

module Pubid
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
      attr_accessor :base

      # Subclasses MUST implement to_s to define how they render
      def to_s
        raise NotImplementedError, "Subclasses must implement to_s method"
      end

      # CSA composites serialise through `to_s`, so MR mirrors that with
      # ` ` → `.`, `:` → `.`, `/` → `-`, then lowercased (issue #142).
      def to_mr_string
        to_s.tr(" ", ".").tr(":", ".").tr("/", "-").downcase
      end

      def to_slug
        to_mr_string
      end

      # CSA composites are not Pubid::Identifier objects, so they do not inherit
      # #root. They are their own origin for matching purposes.
      def root
        self
      end
    end
  end
end
