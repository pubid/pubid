# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    module Components
      # TypedStage combines type and stage information for IEEE identifiers
      # Following the proven ISO/IEC/CEN/BSI pattern
      #
      # IEEE has unique requirements:
      # - Draft stages (D1-D9) with different approval levels
      # - "P" (Project) prefix for drafts only
      # - ISO stage equivalents for joint development (ISO/IEC/IEEE)
      # - Bidirectional format conversion capability
      #
      # Key IEEE stage distinctions:
      # - Unapproved Draft: Working drafts (D1-D6)
      # - Approved Draft: Board-approved but unpublished (D7-D9)
      # - Published: Final standards (no P prefix)
      class TypedStage < Lutaml::Model::Serializable
        # All recognized abbreviations for this stage
        # First in array is canonical abbreviation
        attribute :abbr, :string, collection: true

        # IEEE-specific stage code
        # Values: published, working_draft, committee_draft, draft_standard,
        #         final_draft, preliminary, new_proposal
        attribute :stage_code, :string

        # Document type code
        # Values: standard, draft
        attribute :type_code, :string

        # ISO stage equivalent for joint development (optional)
        # Values: PWI, NP, WD, CD, DIS, FDIS, or nil
        attribute :iso_stage_equivalent, :string

        # IEEE draft notation equivalent (optional)
        # Values: D1, D2-D3, D4-D6, D7-D9, P, or nil
        attribute :ieee_draft_equivalent, :string

        # Approval status
        # Values: unapproved, approved, published
        attribute :approval_status, :string

        # Whether "P" (Project) prefix applies
        # true for all draft stages, false for published
        attribute :project_status, :boolean, default: -> { false }

        # Convert to IEEE format representation
        # @return [String] IEEE format abbreviation
        def to_ieee_format
          return abbr.first unless project_status

          ieee_draft_equivalent || "P"
        end

        # Convert to ISO format representation
        # @return [String] ISO format stage code
        def to_iso_format
          iso_stage_equivalent || abbr.first
        end

        # Get canonical abbreviation (first in list)
        # @return [String] canonical abbreviation
        def canonical_abbreviation
          abbr.first
        end

        # Check if this is a draft stage
        # @return [Boolean] true if draft, false if published
        def draft?
          project_status || approval_status != "published"
        end

        # Check if board-approved
        # @return [Boolean] true if approved or published
        def approved?
          ["approved", "published"].include?(approval_status)
        end

        # Get display name for stage
        # @return [String] human-readable stage name
        def name
          case stage_code
          when "published" then "Published Standard"
          when "working_draft" then "Working Draft"
          when "committee_draft" then "Committee Draft"
          when "draft_standard" then "Draft Standard"
          when "final_draft" then "Final Draft"
          when "preliminary" then "Preliminary Work Item"
          when "new_proposal" then "New Work Item Proposal"
          else stage_code.to_s.split("_").map(&:capitalize).join(" ")
          end
        end
      end
    end
  end
end
