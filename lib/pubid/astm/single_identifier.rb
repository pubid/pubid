# frozen_string_literal: true

module Pubid
  module Astm
    # Descends from Pubid::Astm::Identifier (the flavor base) so every concrete
    # ASTM identifier is `is_a?(Pubid::Astm::Identifier)`.
    class SingleIdentifier < Identifier
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
