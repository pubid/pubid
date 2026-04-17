module Pubid
  module Iec
    module Identifier
      class OperationalDocument < Base
        def_delegators "Pubid::Iec::Identifier::OperationalDocument", :type

        def self.type
          { key: :od, title: "Operational Document", short: "OD" }
        end

        def to_h(deep: true, add_type: true)
          result = super(deep: deep, add_type: false)
          result[:type] = "OD" if add_type
          result
        end
      end
    end
  end
end
