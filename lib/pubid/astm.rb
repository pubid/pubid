# frozen_string_literal: true

require "parslet"
require "lutaml/model"
require_relative "identifier"
require_relative "astm/identifier"
require_relative "astm/components/code"
require_relative "astm/single_identifier"
require_relative "astm/parser"
require_relative "astm/builder"

# Identifier classes
require_relative "astm/identifiers/base"
require_relative "astm/identifiers/standard"
require_relative "astm/identifiers/iso_dual_published"
require_relative "astm/identifiers/manual"
require_relative "astm/identifiers/research_report"
require_relative "astm/identifiers/data_series"
require_relative "astm/identifiers/technical_report"
require_relative "astm/identifiers/monograph"
require_relative "astm/identifiers/adjunct"
require_relative "astm/identifiers/work_in_progress"

# Scheme (must be loaded after identifiers)
require_relative "astm/scheme"

module Pubid
  module Astm
    def self.parse(str)
      Identifier.parse(str)
    end
  end

  # Register this flavor with the Pubid registry
end

# Register Uastm flavor with the registry
Pubid::Registry.register(:astm, Pubid::Astm)
