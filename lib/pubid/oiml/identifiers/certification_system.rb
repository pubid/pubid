# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      # OIML-CS certification-system documents ("OIML-CS PD-05 Edition 6").
      # The number keeps its printed zero padding ("05"); family is the
      # PD/OD/CID document class; the print states "Edition N" instead of a
      # year, and may carry a parenthesized trailing amendment.
      class CertificationSystem < SingleIdentifier
        attribute :number, :string
        attribute :family, :string
        attribute :amendment, :string
        # "PD 05" prints space-separated where "PD-05" is dash-joined.
        attribute :space_separator, :boolean, default: false

        key_value do
          map "number", to: :number
          map "family", to: :family
          map "amendment", to: :amendment
          map "space_separator", to: :space_separator
        end

        def self.subset_ignored_attributes
          super + [:space_separator]
        end

        def type_string
          "CS"
        end

        # `OIML-CS` names the OIML Certification System as one unit, so
        # `with_publisher: false` drops it whole (`PD-05 Edition 6`) and never
        # leaves a bare `CS`.
        def publisher_prefixes
          ["#{publisher}-#{type_string}", "#{publisher} #{type_string}"]
        end
      end
    end
  end
end
