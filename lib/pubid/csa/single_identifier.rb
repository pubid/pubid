# frozen_string_literal: true

module Pubid
  module Csa
    class SingleIdentifier < Pubid::Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation

      attribute :code, Components::Code
      attribute :no_number, :string
      attribute :year, :string
      attribute :year_format, :string  # "colon" or "dash"
      attribute :year_prefix, :string  # "F" or "M"
      attribute :original_year_4digit, :boolean, default: -> {
        false
      } # Track if original input was 4-digit (e.g., "M1981" vs "M83")
      attribute :french, :boolean
      attribute :reaffirmation, :string
      attribute :original_reaffirmation_4digit, :boolean, default: -> {
        false
      } # Track if original reaffirmation was 4-digit (e.g., "R2004" vs "R04")
      attribute :has_publisher, :boolean  # Track if CSA prefix present
      attribute :series_prefix, :string   # MH, RV, etc.
      attribute :series, :boolean         # Track if SERIES keyword present
      attribute :package, :string         # Package portion (Code, Handbook, etc.)
      attribute :publisher_prefix, :string # Original prefix: "CAN/CSA-", "CSA", "CAN3-"
    end
  end
end
