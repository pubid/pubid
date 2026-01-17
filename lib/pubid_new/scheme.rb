# frozen_string_literal: true
module PubidNew
  # < Lutaml::Model::Serializable
  class Scheme
    # attribute :name, :string
    # attribute :version, :string
    attr_accessor :identifiers,
                  :stages,
                  :types,
                  :languages,
                  :publishers,
                  :supplement_identifiers

    def initialize(
      identifiers: [], stages: [], types: [], languages: [], publishers: [],
      supplement_identifiers: []
    )
      @identifiers = identifiers
      @supplement_identifiers = supplement_identifiers
      @stages = stages
      @types = types
      @languages = languages
      @publishers = publishers
    end

    def configure
      yield self if block_given?
    end

    def typed_stages
      return @identifier_typed_stages if @identifier_typed_stages

      @identifier_typed_stages = @identifiers.inject([]) do |acc, identifier_class|
        acc.concat(identifier_class.const_get(:TYPED_STAGES))
      end
    end

    def supplement_typed_stages
      return @supplement_identifier_typed_stages if @supplement_identifier_typed_stages

      @supplement_identifier_typed_stages = @supplement_identifiers.inject([]) do |acc, identifier_class|
        acc.concat(identifier_class.const_get(:TYPED_STAGES))
      end
    end

    def all_typed_stages
      @all_typed_stages ||= (typed_stages + supplement_typed_stages).sort_by do |ts|
        ts.abbr.first
      end.reverse
    end

    def locate_typed_stage_by_abbr(abbr)
      typed_stage = all_typed_stages.detect do |typed_stage|
        typed_stage.abbr.include?(abbr)
      end

      unless typed_stage
        raise ArgumentError,
              "Unknown type abbreviation: '#{abbr}'"
      end

      typed_stage
    end

    def all_identifier_classes_by_type_code
      @all_identifier_classes ||= (@identifiers + @supplement_identifiers).sort_by do |klass|
        klass.type[:key].to_s
      end
    end

    def locate_identifier_klass_by_type_code(type_code)
      identifier_klass = all_identifier_classes_by_type_code.detect do |identifier_class|
        identifier_class.type[:key].to_s == type_code
      end

      unless identifier_klass
        raise ArgumentError,
              "Unknown type code: #{type_code}"
      end

      identifier_klass
    end
  end
end
