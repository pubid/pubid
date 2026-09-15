# frozen_string_literal: true

require "pubid"
module Pubid
  # Parses URN strings back into Identifier objects.
  #
  # Each flavor's {UrnParser} inverts the corresponding {UrnGenerator}. The
  # {Base} class provides shared utilities (validation, splitting, dispatch
  # back to the flavor's text parser); subclasses implement the per-flavor
  # field reconstruction.
  module UrnParser
    autoload :Base, "pubid/urn_parser/base"
    autoload :Errors, "pubid/urn_parser/errors"
  end
end
