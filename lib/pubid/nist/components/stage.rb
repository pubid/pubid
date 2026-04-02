# frozen_string_literal: true

require "lutaml/model"
require "yaml"

module Pubid
  module Nist
    module Components
      # Stage component for NIST draft identifiers
      # Combines id (i/f/1-9) with type (pd/wd/prd)
      #
      # Examples:
      #   Stage.new(id: "i", type: "pd").to_s(:short) # => "ipd"
      #   Stage.new(id: "f", type: "pd").to_s(:long)  # => "(Final Public Draft)"
      class Stage < Lutaml::Model::Serializable
        attribute :id, :string          # i, f, 1-9
        attribute :type, :string        # pd, wd, prd

        # Load stages from V1 YAML config
        STAGES = YAML.load_file(
          File.join(File.dirname(__FILE__),
                    "../../../../archived-gems/pubid-nist/stages.yaml"),
        ).freeze

        # Render stage in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted stage representation
        def to_s(format = :short)
          return "" if id.nil? || type.nil?

          case format
          when :short, :mr
            "#{id}#{type}"
          when :long
            "(#{STAGES['id'][id]} #{STAGES['type'][type]})"
          else
            "#{id}#{type}"
          end
        end

        # Validate stage id and type against YAML config
        def validate!
          unless STAGES["id"].key?(id.to_s)
            raise ArgumentError, "Invalid stage id: #{id.inspect}"
          end
          unless STAGES["type"].key?(type.to_s)
            raise ArgumentError, "Invalid stage type: #{type.inspect}"
          end
        end
      end
    end
  end
end
