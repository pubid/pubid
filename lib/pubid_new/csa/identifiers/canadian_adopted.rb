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
          # For CAN3- identifiers, don't add CAN/ prefix (CAN3- is already complete)
          # For CAN/CSA- identifiers, CAN/ wraps CSA- part
          if wrapped_identifier.respond_to?(:publisher_prefix) &&
             wrapped_identifier.publisher_prefix == "CAN3-"
            # CAN3- is standalone, just render wrapped identifier with reaffirmation
            result = wrapped_identifier.to_s
          else
            # Wrapped identifier already has correct format preserved in publisher_prefix
            # Just prepend CAN/ and append reaffirmation if present
            result = "CAN/#{wrapped_identifier}"
          end
          result += " (R#{reaffirmation})" if reaffirmation
          result
        end
      end
    end
  end
end