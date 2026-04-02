# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    module Components
      # ISO Code with number and multi-level parts
      class Code < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :parts, :string, collection: true

        # Alias for compatibility with rendering code
        def value
          number
        end

        def to_s
          result = number.to_s
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def ==(other)
          return false unless other.is_a?(Code)

          number == other.number && parts == other.parts
        end
      end
    end
  end
end
