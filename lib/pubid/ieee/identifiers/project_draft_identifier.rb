# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Project Draft Identifier
      # Format: "IEEE P1234/D5, July 2019"
      # where P1234 is the project number and D5 is the draft version
      # This is distinct from a StandardIdentifier - the "P" indicates project status,
      # not a code prefix like "C" in "C57.12"
      class ProjectDraftIdentifier < Base
        # Override initialize to strip "P" prefix from code before creating Code object
        # The "P" is reflected in the typed_stage, not in the Code component itself
        def initialize(**args)
          # If code is provided with "P" prefix (e.g., "P1234"), strip it
          if args[:code]&.is_a?(String) && args[:code]&.start_with?("P")
            args[:code] = args[:code][1..] # Strip leading "P"
          end

          # Call parent initialize with modified code
          super
        end
      end
    end
  end
end
