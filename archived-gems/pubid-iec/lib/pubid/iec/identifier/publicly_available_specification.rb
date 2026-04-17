module Pubid
  module Iec
    module Identifier
      class PubliclyAvailableSpecification < Base
        def_delegators "Pubid::Iec::Identifier::PubliclyAvailableSpecification",
                       :type

        TYPED_STAGES = {
          cdpas: {
            abbr: "CDPAS",
            name: "Draft circulated as DPAS",
            harmonized_stages: %w[50.20],
          },
          dpas: {
            abbr: "DPAS",
            name: "Draft Publicly Available Specification",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          },
        }.freeze

        PROJECT_STAGES = {
          PRVDPAS: {
            abbr: "PRVDPAS",
            name: "Preparation of RVDPAS",
            harmonized_stages: %w[50.60],
          },
        }.freeze

        def self.type
          { key: :pas, title: "Publicly Available Specification", short: "PAS" }
        end

        def to_h(deep: true, add_type: true)
          result = super(deep: deep, add_type: false)
          result[:type] = "PAS" if add_type
          result
        end
      end
    end
  end
end
