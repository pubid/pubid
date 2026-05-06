# frozen_string_literal: true

require_relative "typed_stages"

module Pubid
  module Ieee
    # Scheme provides registry access for IEEE identifiers
    # Following the proven ISO/IEC/CEN/BSI pattern
    #
    # This class is the single source of truth for:
    # - TypedStage lookup by abbreviation
    # - TypedStage lookup by IEEE draft notation
    # - TypedStage lookup by ISO stage code
    # - Identifier class selection based on type code
    class Scheme < Pubid::Scheme
      class << self
        # Locate typed stage by abbreviation
        # @param abbr [String, nil] stage abbreviation (e.g., "D1", "FDIS", "Std")
        # @return [Components::TypedStage] matching typed stage
        def locate_typed_stage_by_abbr(abbr)
          return TypedStages::DEFAULT_TYPED_STAGE if abbr.nil? || abbr.to_s.strip.empty?

          # Normalize abbreviation
          abbr_str = abbr.to_s.strip

          # Find typed stage that includes this abbreviation
          typed_stage = TypedStages::TYPED_STAGES.find { |ts| ts.abbr.include?(abbr_str) }

          # Fall back to default if not found
          typed_stage || TypedStages::DEFAULT_TYPED_STAGE
        end

        # Locate typed stage by IEEE draft notation
        # @param draft [String] IEEE draft notation (e.g., "D1", "D5", "P")
        # @return [Components::TypedStage, nil] matching typed stage
        def locate_typed_stage_by_ieee_draft(draft)
          return nil if draft.nil? || draft.to_s.strip.empty?

          draft_str = draft.to_s.strip

          # Try exact match on abbreviation first
          ts = TypedStages::TYPED_STAGES.find { |t| t.abbr.include?(draft_str) }
          return ts if ts

          # Try match on ieee_draft_equivalent
          TypedStages::TYPED_STAGES.find { |t| t.ieee_draft_equivalent == draft_str }
        end

        # Locate typed stage by ISO stage code
        # @param stage [String] ISO stage code (e.g., "WD", "CD", "DIS", "FDIS")
        # @return [Components::TypedStage, nil] matching typed stage
        def locate_typed_stage_by_iso_stage(stage)
          return nil if stage.nil? || stage.to_s.strip.empty?

          TypedStages::TYPED_STAGES.find { |ts| ts.iso_stage_equivalent == stage.to_s.strip }
        end

        # Locate identifier class by type code
        # @param type_code [String, Symbol] type code (:standard, :draft, :std, :P, etc.)
        # @return [Class] identifier class
        def locate_identifier_klass_by_type_code(type_code)
          type_str = type_code.to_s

          case type_str
          when "draft", "Draft Std", "Draft", "P"
            # "P" indicates project draft status - maps to ProjectDraftIdentifier
            Identifiers::ProjectDraftIdentifier
          when "standard", "Std", "std"
            Identifiers::Standard
          else
            # Default to base identifier
            Identifiers::Base
          end
        end

        # Get all typed stages
        # @return [Array<Components::TypedStage>] all registered typed stages
        def typed_stages
          TypedStages::TYPED_STAGES
        end

        # Get default typed stage (published standard)
        # @return [Components::TypedStage] default typed stage
        def default_typed_stage
          TypedStages::DEFAULT_TYPED_STAGE
        end
      end
    end
  end
end
