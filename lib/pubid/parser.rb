# frozen_string_literal: true

require "pubid"
module Pubid
  module Parser
    autoload :Grammar, "pubid/parser/grammar"
    autoload :CommonParseMethods, "pubid/parser/common_parse_methods"
    autoload :CommonParseRules, "pubid/parser/common_parse_rules"
  end
end
