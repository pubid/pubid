# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Iso
    module Components
      # ISO Publisher with copublisher support
      # Examples: ISO, ISO/IEC, ISO/IEC/IEEE
      class Publisher < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "ISO" }
        attribute :copublisher, :string, collection: true

        def to_s
          result = publisher
          result += copublisher.map { |cp| "/#{cp}" }.join if copublisher&.any?
          result
        end

        def has_copublisher?
          copublisher&.any?
        end

        def ==(other)
          return false unless other.is_a?(Publisher)

          publisher == other.publisher && copublisher == other.copublisher
        end
      end
    end
  end
end
