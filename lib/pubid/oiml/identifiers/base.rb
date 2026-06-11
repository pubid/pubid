# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      class Base < Pubid::Identifier
        attribute :publisher, :string
        attribute :type, :string
        attribute :code, Oiml::Components::Code
        attribute :date, Pubid::Components::Date
        attribute :stage, :string
        attribute :iteration, :string
        attribute :language, :string

        def to_s(**opts)
          render(format: :human, **opts)
        end
      end
    end
  end
end
