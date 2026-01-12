require_relative "../renderer/base"

module Pubid::Cen
  module Identifier
    class EuropeanNorm < Base
      def_delegators "Pubid::Cen::Identifier::EuropeanNorm", :type

      def self.type
        { key: :en, title: "European Norm", short: "EN" }
      end

      def self.type_match?(parameters)
        return true if parameters[:publisher] == "EN" && parameters[:type].nil?
        return true if parameters[:type]&.to_s&.downcase == "en"

        false
      end

      def initialize(**opts)
        super(**opts)
      end

      def self.get_renderer_class
        Renderer::Base
      end
    end
  end
end
