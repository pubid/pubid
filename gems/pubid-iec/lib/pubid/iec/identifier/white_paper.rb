module Pubid::Iec
  module Identifier
    class WritePaper < Base
      def_delegators 'Pubid::Iec::Identifier::WritePaper', :type

      def self.type
        { key: :wp, title: "Write Paper", short: "White Paper" }
      end

      def to_h(deep: true, add_type: true)
        result = super(deep: deep, add_type: false)
        result[:type] = "White Paper" if add_type
        result
      end
    end
  end
end
