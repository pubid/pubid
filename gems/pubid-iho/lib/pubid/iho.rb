# frozen_string_literal: true

require "parslet"

module Pubid
  module Iho
  end
end

require "pubid-core"

require_relative "iho/version"
require_relative "iho/errors"
require_relative "iho/identifier"
require_relative "iho/identifier/base"
require_relative "iho/renderer/base"

config = Pubid::Core::Configuration.new
config.default_type = Pubid::Iho::Identifier::Base
config.types = [Pubid::Iho::Identifier::Base]

config.type_names = {
  s: {
    long: "Standards and Specifications",
    short: "S",
  },
  p: {
    long: "Publication",
    short: "P",
  },
  m: {
    long: "Miscellaneous Publication",
    short: "M",
  },
  b: {
    long: "Bibliographic Publication",
    short: "B",
  },
  c: {
    long: "Circular Letter",
    short: "C",
  },
}
Pubid::Iho::Identifier.set_config(config)

require_relative "iho/parser"
