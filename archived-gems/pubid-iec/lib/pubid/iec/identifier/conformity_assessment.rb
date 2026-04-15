module Pubid::Iec
  module Identifier
    class ConformityAssessment < Base
      def_delegators "Pubid::Iec::Identifier::ConformityAssessment", :type

      def self.type
        { key: :ca, title: "Conformity Assessment", short: "CA" }
      end

      def to_h(deep: true, add_type: true)
        result = super(deep: deep, add_type: false)
        result[:type] = "CA" if add_type
        result
      end
    end
  end
end
