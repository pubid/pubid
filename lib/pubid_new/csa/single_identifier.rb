# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :code, Components::Code
      attribute :no_number, :string
      attribute :year, :string
      attribute :year_format, :string  # "colon" or "dash"
      attribute :year_prefix, :string  # "F" or "M"
      attribute :french, :boolean
      attribute :reaffirmation, :string
      attribute :has_publisher, :boolean  # Track if CSA prefix present
      attribute :series_prefix, :string   # MH, RV, etc.
      attribute :series, :boolean         # Track if SERIES keyword present
      attribute :package, :string         # Package portion (Code, Handbook, etc.)
      attribute :publisher_prefix, :string # Original prefix: "CAN/CSA-", "CSA", "CAN3-"
    end
  end
end
