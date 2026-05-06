# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # Base class for all IHO identifiers.
      #
      # IHO identifiers have the form:
      #   IHO {S|P|M|B|C}-{code}[ Ap. {appendix}][ Part {part}][ Annex {annex}][ Suppl {supplement}][ {version}]
      #
      # The leading IHO publisher prefix is optional on input but always
      # emitted on output.
      class Base < Lutaml::Model::Serializable
        attribute :publisher,  :string, default: "IHO"
        attribute :code,       :string
        attribute :appendix,   :string
        attribute :part,       :string
        attribute :annex,      :string
        attribute :supplement, :string
        attribute :version,    :string

        def self.parse(string)
          Iho::Identifier.parse(string)
        end

        # Render the identifier as a string in canonical IHO form.
        # @return [String]
        def to_s
          letter = type.is_a?(Hash) ? type[:short].to_s : type.to_s
          rendered = "#{publisher} #{letter}-#{code}"
          rendered << " Ap. #{appendix}" if appendix
          rendered << " Part #{part}"    if part
          rendered << " Annex #{annex}"  if annex
          rendered << " Suppl #{supplement}" if supplement
          rendered << " #{version}" if version
          rendered
        end
      end
    end
  end
end
