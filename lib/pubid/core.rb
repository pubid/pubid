# frozen_string_literal: true

require "pubid"
module Pubid
  # Core module for shared functionality across all flavors.
  module Core
    autoload :UpdateCodes, "#{__dir__}/core/update_codes"
  end
end
