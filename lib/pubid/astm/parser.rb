# frozen_string_literal: true

module Pubid
  module Astm
    class Parser
      # SEMANTIC NOTE: 5xxxx digit-only standards are ISO/ASTM dual-published
      # Examples:
      #   ASTM 52303-24e1: ASTM's version (e1 = edition 1, not "E" prefix)
      #   ISO/ASTM 52303:2024: ISO's published version of the same document
      # These should semantically be IsoDualPublishedIdentifier or similar
      # Parser currently accepts them as digit-only standards

      # NOTE: Reference Radiographs (RR) are a separate document type not yet implemented
      # Examples:
      #   RRE341903: Reference radiograph for standard E3419
      #   RRE015501: Reference radiograph, volume 1
      #   RRE2669CS: Adjunct to E2669 reference radiograph
      # These require separate ReferenceRadiograph identifier class
    end
  end
end
