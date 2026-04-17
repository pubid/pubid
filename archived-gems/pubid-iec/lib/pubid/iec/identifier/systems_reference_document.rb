module Pubid
  module Iec
    module Identifier
      class SystemsReferenceDocument < Base
        def_delegators "Pubid::Iec::Identifier::SystemsReferenceDocument", :type

        def self.type
          { key: :srd, title: "Systems Reference Document", short: "SRD" }
        end

        def to_h(deep: true, add_type: true)
          result = super(deep: deep, add_type: false)
          result[:type] = "SRD" if add_type
          result
        end
      end
    end
  end
end
