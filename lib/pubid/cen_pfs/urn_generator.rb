module Pubid
  module CenPfs
    # The official URN generator, pinned to the scheme's declared
    # namespace ("cen") so to_urn stays
    # scheme-canonical under the compiled flavor key.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "cen"
      end
    end
  end
end
