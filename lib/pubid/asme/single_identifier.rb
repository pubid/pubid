# frozen_string_literal: true


module Pubid
  module Asme
    class SingleIdentifier < Lutaml::Model::Serializable

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      attribute :publisher, :string
      attribute :code, Components::Code
      attribute :year, :string
      attribute :reaffirmation, :string     # R2020
      attribute :language, :string          # (SPANISH)
      attribute :csa_number, :string        # CSA dual-published number
      attribute :draft_year, :string        # 20XX or 202X for drafts
      attribute :revision_note, :string     # [Draft Proposed Revision of ...]
      attribute :parenthetical_revision, :string # (Revision of ASME ...)
      attribute :handbook, :boolean, default: -> { false } # Handbook flag
      attribute :ptc_suffix, :string # PTC suffix like "TW" or "PM"

      # Joint published attributes
      attribute :joint_publisher, :string   # ISO/ASME or ASME/ANS
      attribute :first_publisher, :string   # CSA or API (when first)
      attribute :first_code, :string        # Code from first publisher
      attribute :second_publisher, :string  # ASME (when second)
    end
  end
end
