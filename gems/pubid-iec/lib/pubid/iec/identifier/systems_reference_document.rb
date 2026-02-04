module Pubid::Iec
  module Identifier
    class SystemsReferenceDocument < Base
      def_delegators 'Pubid::Iec::Identifier::SystemsReferenceDocument', :type

      def self.type
        { key: :srd, title: "Systems Reference Document", short: "SRD" }
      end

      def to_h(deep: true)
        super(deep: deep).merge(type: "SRD")
      end
    end
  end
end
