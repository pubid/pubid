# frozen_string_literal: true

require "parsanol"

module Pubid
  module Parg
    autoload :Artifact, "pubid/parg/artifact"
    autoload :Backend, "pubid/parg/backend"
    autoload :Model, "pubid/parg/model"

    # The engine errors a PG artifact can raise while parsing or binding an
    # input. Every one of them must surface as Pubid::Errors::ParseError —
    # the uniform error contract (CLAUDE.md "One error namespace") makes
    # `rescue Pubid::Errors::Error` exhaustive, and a raw Parsanol class
    # escaping Pubid.parse bypasses every such guard (issue #646: the JIS
    # year forms raised Parsanol::PARG::BindError raw, which is NOT a
    # Parsanol::ParseFailed). PARG::Error carries BindError
    # (< ArtifactError < Error) and the PARG Parse/Compile/Artifact errors;
    # Parsanol::ParseFailed is the ruby reference engine's parse failure.
    ENGINE_ERRORS = [Parsanol::ParseFailed, Parsanol::PARG::Error].freeze
  end
end
