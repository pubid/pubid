# frozen_string_literal: true

require "lutaml/model"
require_relative "urn_generator"
require_relative "../serializable"

module PubidNew
  module Csa
    class SingleIdentifier < Lutaml::Model::Serializable
      include PubidNew::Serializable

      # Generate URN for this identifier
      #
      # @return [String] URN representation
      def to_urn
        UrnGenerator.new(self).generate
      end

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
