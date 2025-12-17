# frozen_string_literal: true

require_relative "../wrapper_identifier"

module PubidNew
  module Csa
    module Identifiers
      # CanadianAdoptedIdentifier represents Canadian adoption of standards
      # indicated by the CAN/ prefix wrapper.
      #
      # Examples:
      #   CAN/CSA-C22.2 NO. 60601-1-9:15
      #   CAN/CSA-Z662:23 (R2024)
      #
      # This is a wrapper pattern where:
      #   - CAN/ indicates Canadian adoption
      #   - The wrapped_identifier is the actual CSA standard being adopted
      #
      # This is semantically different from a string prefix because:
      #   - CAN/ wraps an entire identifier (which may itself be complex)
      #   - The wrapped identifier is recursively parsed as a full CSA identifier
      #   - Proper object composition, not string manipulation
      class CanadianAdopted < WrapperIdentifier
        def to_s
          # Wrapped identifier already has correct format preserved in publisher_prefix
          # Just prepend CAN/ and append reaffirmation if present
          result = "CAN/#{wrapped_identifier}"
          result += " (R#{reaffirmation})" if reaffirmation
          result
        end
      end
    end
  end
end