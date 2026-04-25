module Pubid::Iho
  module Identifier
    class Base < Pubid::Core::Identifier::Base
      attr_accessor :version, :appendix

      def self.type
        { key: :iho }
      end

      def initialize(type:, publisher: "IHO", version: nil, part: nil, appendix: nil, **opts)
        super(**opts.merge(publisher: publisher))
        @part = part.to_s if part
        @version = version.to_s if version
        @appendix = appendix.to_s if appendix
        if type
          unless Identifier.config.type_names.map { |_, v| v[:short] }.include?(type.to_s)
            raise Pubid::Core::Errors::WrongTypeError, "Type '#{type}' is not available"
          end
          @type = type.to_s
        end
      end

      class << self
        def transform(params)
          identifier_params = params.map do |k, v|
            get_transformer_class.new.apply(k => v)
          end.inject({}, :merge)

          Identifier.create(**identifier_params)
        end

        def get_parser_class
          Parser
        end

        def get_renderer_class
          Renderer::Base
        end
      end
    end
  end
end
