# frozen_string_literal: true

require "parsanol"

module Pubid
  module Parg
    # A baked, checksum-verified PG artifact for one flavor. The artifact
    # is the parser of record for the flavor: its grammar, tests, entries,
    # and embedded tables travel together and are verified on load.
    class Artifact
      DATA_DIR = File.expand_path("../../../data/parg", __dir__)
      # The deferred entity atoms resolve from_table references at parse
      # time from this dir, so the table YAMLs vendor alongside the
      # baked artifacts.
      TABLES_DIR = File.join(DATA_DIR, "tables")

      @artifacts = {}

      class << self
        # Load and memoize the artifact for a flavor (e.g. :iso).
        def for(flavor)
          @artifacts[flavor] ||=
            begin
              new(Parsanol::PARG::Artifact.load(path_for(flavor),
                                                tables_dir: TABLES_DIR))
            rescue Parsanol::PARG::Error => e
              raise Pubid::Errors::ParseError,
                    "PG artifact #{path_for(flavor)} rejected: #{e.message}"
            end
        end

        # The vendored artifact's path. PG::Lutaml.register loads the file
        # itself, so model registration needs the path, not the wrapper.
        def path_for(flavor)
          File.join(DATA_DIR, "#{flavor}.json")
        end
      end

      def initialize(artifact)
        @artifact = artifact
      end

      def parse(entry, input)
        @artifact.parse(entry, input)
      end

      # The bindings the grammar declared for +entry+, empty when it
      # declares none.
      def bindings(entry)
        @artifact.envelope.dig("entries", entry, "bindings") || []
      end

      def checksum
        @artifact.envelope["checksum"]
      end
    end
  end
end
