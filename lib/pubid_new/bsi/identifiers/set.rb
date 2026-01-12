# frozen_string_literal: true

require "lutaml/model"
require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Set represents multiple standards published as a set
      # Format: {identifier} + {identifier} [+ {identifier} ...]
      # Each identifier is separated by " + " (space, plus, space)
      #
      # Examples:
      #   BS ISO 20400 + BS ISO 44001+BS ISO 44002
      #   BS ISO 9001+BS ISO 14001
      class Set < Base
        attribute :identifiers, Base, collection: true, polymorphic: true
        attribute :separators, :string, collection: true  # Should all be " + "

        def to_s(lang: :en, lang_single: false)
          return "" if identifiers.nil? || identifiers.empty?

          parts = []

          identifiers.each_with_index do |id, i|
            # Render each identifier
            parts << id.to_s

            # Add separator (always " + " between identifiers)
            if i < identifiers.length - 1
              parts << " + "
            end
          end

          parts.join("")
        end

        def <=>(other)
          return nil unless other.is_a?(Set)

          # Compare first identifier
          identifiers.first <=> other.identifiers.first
        end
      end
    end
  end
end
