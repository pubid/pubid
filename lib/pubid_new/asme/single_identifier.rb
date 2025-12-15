# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Asme
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :publisher, :string
      attribute :code, Components::Code
      attribute :year, :string
      attribute :reaffirmation, :string     # R2020
      attribute :language, :string          # (SPANISH)
      attribute :csa_number, :string        # CSA dual-published number
      attribute :draft_year, :string        # 20XX or 202X for drafts
      attribute :revision_note, :string     # [Draft Proposed Revision of ...]
    end
  end
end
