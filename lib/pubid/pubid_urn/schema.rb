# frozen_string_literal: true

module Pubid
  module PubidUrn
    # One prefixed atom: an optional value, found by its prefix and not by
    # its position ("part-1", "co-IEC,IEEE", "ids-(iso:is:9001)").
    #
    # +path+ is a dotted key path into the node's +to_hash+; "*" walks the
    # elements of an Array ("languages.*.code"). +kind+ is one of
    # :string, :list, :bool, :int, :id (a nested identifier hash) or :ids
    # (an Array of them). A path with "*" is always a :list.
    Atom = Struct.new(:path, :prefix, :kind) do
      def parts
        @parts ||= path.split(".")
      end

      def list?
        kind == :list
      end
    end

    # A spelling-only value (+original_code+, +original_text+ …). Facets are
    # written in the trailing "f" group, so a consumer can cut them off a slug.
    Facet = Struct.new(:path, :name) do
      def parts
        @parts ||= path.split(".")
      end

      def list?
        parts.include?("*")
      end
    end

    # The URN shape of one concrete identifier type.
    class TypeSchema
      attr_reader :flavor, :type, :token, :core, :atoms, :facets

      def initialize(flavor:, type:, token:, core:, atoms:, facets:)
        @flavor = flavor
        @type = type
        @token = token
        @core = core.map { |path| path.split(".") }.freeze
        @atoms = atoms.freeze
        @facets = facets.freeze
        @atom_index = atoms.each_with_index.to_h { |atom, i| [atom.prefix, i] }
        @facet_names = facets.to_h { |facet| [facet.name, facet] }
      end

      # @return [Integer, nil] the canonical position of the atom whose
      #   prefix starts +token+, or nil when +token+ is no atom of this type
      def atom_position(token)
        prefix = token[/\A([a-z0-9]+)-/, 1]
        prefix && @atom_index[prefix]
      end

      def facet(name)
        @facet_names[name]
      end
    end

    # The pubid-scheme schema of one flavor: the canonical atom order, the
    # facets, and one TypeSchema for each concrete type.
    #
    # Atoms and facets declared at flavor level apply to every type, in the
    # order of declaration; a type adds its own after them. A type token, an
    # atom prefix and a facet name are a lower-case letter followed by
    # lower-case letters and digits, so none can contain the "-" that ends a
    # prefix or the "." that qualifies a token of another flavor, and each
    # has the shape PubidUrn::STRUCTURE reads as structure.
    class FlavorSchema
      NAME = /\A[a-z][a-z0-9]*\z/
      KINDS = %i[string list bool int id ids].freeze
      # "f" opens the facet group; "type" is the type-metadata URN
      # (Pubid::IdentifierMetadata, "urn:pubid:<flavor>:type:<key>").
      RESERVED_TOKENS = %w[f type].freeze

      attr_reader :flavor, :types

      def initialize(flavor)
        @flavor = flavor
        @atoms = []
        @facets = []
        @types = {}
        @tokens = {}
      end

      def atom(path, prefix, kind: nil)
        @atoms << build_atom(path, prefix, kind)
      end

      def facet(path, name)
        check_name!(name, "facet name")
        @facets << Facet.new(path, name)
      end

      # @param type [String] the +_type+ the class serializes
      # @param token [String] the short type token of the URN
      # @param core [Array<String>] the positional core paths
      # @param atoms [Array<Array>] extra atoms: [path, prefix, kind]
      def type(type, token, core: %w[number], atoms: [], facets: [])
        check_name!(token, "type token")
        if RESERVED_TOKENS.include?(token) || @tokens.key?(token)
          raise ArgumentError, 
                "type token #{token.inspect} is reserved or taken"
        end

        all_atoms = @atoms + atoms.map { |spec| build_atom(*spec) }
        check_unique!(all_atoms.map(&:prefix), "atom prefix", type)
        all_facets = @facets + facets.map { |path, name| Facet.new(path, name) }
        check_unique!(all_facets.map(&:name), "facet name", type)

        schema = TypeSchema.new(flavor: flavor, type: type, token: token,
                                core: core, atoms: all_atoms,
                                facets: all_facets)
        @types[type] = schema
        @tokens[token] = schema
      end

      def for_token(token)
        @tokens[token]
      end

      def for_type(type)
        @types[type]
      end

      private

      def build_atom(path, prefix, kind = nil)
        check_name!(prefix, "atom prefix")
        kind ||= path.include?("*") ? :list : :string
        unless KINDS.include?(kind)
          raise ArgumentError, "unknown atom kind #{kind.inspect}"
        end

        Atom.new(path, prefix, kind)
      end

      def check_name!(name, what)
        return if NAME.match?(name)

        raise ArgumentError, "#{what} #{name.inspect} must match #{NAME.source}"
      end

      def check_unique!(names, what, type)
        dup = names.tally.find { |_, count| count > 1 }
        return unless dup

        raise ArgumentError, "#{what} #{dup.first.inspect} repeats in #{type}"
      end
    end
  end
end
