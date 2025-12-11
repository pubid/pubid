# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Handles ISO/IEC/IEEE joint development identifiers
      # Supports bidirectional format conversion between IEEE and ISO representations
      #
      # Joint development standards can be represented in two formats:
      #
      # IEEE Format:
      #   ISO/IEC/IEEE P26511/D8-2018
      #   - Publishers: ISO/IEC/IEEE (slash-separated)
      #   - P prefix indicates draft
      #   - /D8 indicates IEEE draft notation
      #   - Dash before year
      #
      # ISO Format:
      #   ISO/IEC/IEEE FDIS 26511:2018
      #   - Publishers: ISO/IEC/IEEE (slash-separated)
      #   - ISO stage code (FDIS) instead of P/D notation
      #   - Colon before year
      #
      # Key principles:
      # - NO equivalence mapping (as per IEEE staff guidance)
      # - "P" prefix means IEEE draft (any stage)
      # - ISO stages and IEEE drafts can coexist
      # - Format conversion preserves semantic meaning
      class JointDevelopment < Base
        attribute :publishers, :string, collection: true
        attribute :code, :string
        attribute :typed_stage, Components::TypedStage
        attribute :year, :string
        attribute :rendering_format, :string, default: -> { "ieee" }
        attribute :iso_stage, :string  # For ISO stage if present
        attribute :ieee_draft, :string # For IEEE P/D notation if present

        def initialize(**args)
          # Handle typed_stage
          if args[:typed_stage].is_a?(Components::TypedStage)
            self.typed_stage = args[:typed_stage]
          end

          # Set publishers
          if args[:publishers]
            self.publishers = args[:publishers]
          elsif args[:publisher] && args[:copublisher]
            # Combine publisher and copublisher into publishers array
            self.publishers = [args[:publisher], *args[:copublisher]].compact
          end

          super(**args)
        end

        # Convert to string representation
        # @return [String] formatted identifier
        def to_s
          case rendering_format
          when "iso"
            to_iso_format
          when "ieee"
            to_ieee_format
          else
            to_ieee_format
          end
        end

        private

        # Convert to ISO format representation
        # ISO/IEC/IEEE FDIS 26511:2018
        # @return [String] ISO format string
        def to_iso_format
          parts = []

          # Publishers (slash-separated)
          parts << publishers.join("/") if publishers && !publishers.empty?

          # ISO stage code
          if typed_stage
            parts << typed_stage.to_iso_format
          elsif iso_stage
            parts << iso_stage
          end

          # Code (remove P prefix if present)
          code_str = code.to_s.gsub(/^P/, "")
          parts << code_str

          # Join with space and add year with colon
          result = parts.join(" ")
          result += ":#{year}" if year

          result
        end

        # Convert to IEEE format representation
        # ISO/IEC/IEEE P26511/D8-2018
        # @return [String] IEEE format string
        def to_ieee_format
          parts = []

          # Publishers (slash-separated)
          parts << publishers.join("/") if publishers && !publishers.empty?

          # Build code part
          code_str = code.to_s.gsub(/^P/, "")  # Remove any existing P

          # Add P prefix if this is a draft (project status)
          if typed_stage&.project_status
            code_str = "P#{code_str}"
          elsif ieee_draft
            # Has explicit IEEE draft notation
            code_str = "P#{code_str}" unless code_str.start_with?("P")
          end

          # Add IEEE draft notation if available
          if typed_stage&.ieee_draft_equivalent
            code_str += "/#{typed_stage.ieee_draft_equivalent}"
          elsif ieee_draft
            code_str += "/#{ieee_draft}"
          end

          parts << code_str

          # Join with space and add year with dash
          result = parts.join(" ")
          result += "-#{year}" if year

          result
        end

        # Override to ensure proper publisher handling
        def publisher
          publishers&.first || super
        end

        # Override to ensure proper copublisher handling
        def copublisher
          publishers&.drop(1) || super
        end
      end
    end
  end
end