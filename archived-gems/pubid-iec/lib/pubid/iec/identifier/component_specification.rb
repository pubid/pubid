module Pubid::Iec
  module Identifier
    class ComponentSpecification < Base
      def_delegators "Pubid::Iec::Identifier::ComponentSpecification", :type

      def self.type
        { key: :cs, title: "Component Specification", short: "CS" }
      end

      def to_h(deep: true, add_type: true)
        result = super(deep: deep, add_type: false)
        result[:type] = "CS" if add_type
        result
      end
    end
  end
end
