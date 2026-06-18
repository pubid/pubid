# frozen_string_literal: true

module Pubid
  module Astm
    class SingleIdentifier < Pubid::Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation
      attribute :publisher, :string, default: -> { "ASTM" }
      attribute :code, Components::Code
      attribute :year, :string
      attribute :format_suffix, :string # -EB for eBook
    end
  end
end
