# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    module Components
      # ISO Publisher with copublisher support
      # Examples: ISO, ISO/IEC, ISO/IEC/IEEE
      class Publisher < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "ISO" }
        attribute :copublisher, :string, collection: true

        def body
          publisher
        end

        def render(context: nil)
          if context&.urn?
            return publisher&.downcase
          end

          return publisher unless copublisher&.any?

          publisher + copublisher.map { |cp| "/#{cp}" }.join
        end

        def to_s
          result = publisher
          result += copublisher.map { |cp| "/#{cp}" }.join if copublisher&.any?
          result
        end

        def has_copublisher?
          copublisher&.any?
        end

        def copublished?
          copublisher&.any?
        end

        def ==(other)
          return false unless other.is_a?(Publisher)

          # copublisher is a collection: parsing yields [] while building via
          # .create (e.g. from an index hash) leaves it nil. Treat the empty
          # collection and "no collection" as equal so both forms compare.
          publisher == other.publisher &&
            copublisher.to_a == other.copublisher.to_a
        end

        def hash
          @hash ||= [publisher, copublisher.to_a].map(&:hash).hash
        end

        def eql?(other)
          hash == other.hash && self == other
        end
      end
    end
  end
end
