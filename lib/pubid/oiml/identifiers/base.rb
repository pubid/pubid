# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      class Base < Lutaml::Model::Serializable
        attribute :publisher, :string
        attribute :type, :string
        attribute :code, Oiml::Components::Code
        attribute :date, Pubid::Components::Date
        attribute :stage, :string
        attribute :iteration, :string
        attribute :language, :string

        def to_s
          result = "#{publisher} #{type} #{code}"

          # Add date if present
          result += ":#{date.year}" if date

          # Add draft stage if present (iteration + stage)
          if stage || iteration
            result += " "
            result += iteration.to_s if iteration
            result += stage.to_s if stage
          end

          # Add language portion if present
          result += "(#{language})" if language

          result
        end

        def to_urn
          UrnGenerator.new(self).generate
        end
      end
    end
  end
end
