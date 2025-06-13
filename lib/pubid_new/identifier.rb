require_relative "components/code"
require_relative "components/date"
require_relative "components/edition"
require_relative "components/language"
require_relative "components/locality"
require_relative "components/publisher"
require_relative "components/stage"
require_relative "components/type"

module PubidNew
  # Identifier that
  class Identifier < Lutaml::Model::Serializable
    attribute :number, Components::Code
    attribute :part, Components::Code
    attribute :subpart, Components::Code
    attribute :stage_iteration, Components::Code
    attribute :date, Components::Date
    attribute :edition, Components::Edition
    attribute :languages, Components::Language, collection: true
    attribute :publisher, Components::Publisher
    attribute :copublishers, Components::Publisher, collection: true
    attribute :type, Components::Type
    attribute :stage, Components::Stage
    attribute :locality, Components::Locality
  end
end
