module Pubid
  module DoiPfs
    # The official URN generator, pinned to the scheme's declared
    # namespace ("doi") so to_urn stays
    # scheme-canonical under the compiled flavor key.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "doi"
      end
    end
  end
end
