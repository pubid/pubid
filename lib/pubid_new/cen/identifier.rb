require "lutaml/model"

module PubidNew
  module Cen
    class Identifier < Lutaml::Model::Serializable
      # Base class for all CEN identifiers
      # Subclasses: SingleIdentifier, SupplementIdentifier

      def to_s(lang: :en, lang_single: false)
        raise NotImplementedError, "Subclasses must implement #to_s"
      end

      def <=>(other)
        raise NotImplementedError, "Subclasses must implement #<=>"
      end
    end
  end
end