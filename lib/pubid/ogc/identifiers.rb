# frozen_string_literal: true

module Pubid
  module Ogc
    # Namespace for concrete OGC identifier types.
    module Identifiers
      autoload :Document, "#{__dir__}/identifiers/document"
    end
  end
end
