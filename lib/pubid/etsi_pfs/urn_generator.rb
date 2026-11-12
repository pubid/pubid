module Pubid
  module EtsiPfs
    # The official URN generator, pinned to the scheme's declared
    # namespace ("etsi") so to_urn stays
    # scheme-canonical under the compiled flavor key.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "etsi"
      end
    end
  end
end
