# frozen_string_literal: true

require "parsanol"

module Pubid
  module Pg
    # A baked, checksum-verified PG artifact for one flavor. The artifact
    # is the parser of record for the flavor: its grammar, tests, entries,
    # and embedded tables travel together and are verified on load.
    class Artifact
      DATA_DIR = File.expand_path("../../../data/pg", __dir__)

      @artifacts = {}

      class << self
        # Load and memoize the artifact for a flavor (e.g. :iso).
        def for(flavor)
          @artifacts[flavor] ||= new(File.join(DATA_DIR, "#{flavor}.json"))
        end
      end

      def initialize(path)
        @artifact = Parsanol::PARG::Artifact.load(path)
      rescue Parsanol::PARG::Error => e
        raise Pubid::Errors::ParseError,
              "PG artifact #{path} rejected: #{e.message}"
      end

      def parse(entry, input)
        @artifact.parse(entry, input)
      end

      def checksum
        @artifact.envelope["checksum"]
      end
    end
  end
end
