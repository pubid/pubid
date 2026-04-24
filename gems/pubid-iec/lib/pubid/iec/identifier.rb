module Pubid::Iec
  module Identifier
    IEV_SHORTHAND = /\AIEV(?=\z|[\s\-])/.freeze

    class << self
      include Pubid::Core::Identifier

      def parse(*args)
        if args[0].is_a?(String) && args[0].match?(IEV_SHORTHAND)
          args = args.dup
          args[0] = args[0].sub(IEV_SHORTHAND, "IEC 60050")
        end
        Base.parse(*args)
      end

      def parseable?(pubid)
        return true if pubid.is_a?(String) && pubid.match?(IEV_SHORTHAND)

        super
      end

      def build_project_stage(**args)
        TypedProjectStage.new(config: @config, **args)
      end
    end
  end
end
