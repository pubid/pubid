require "lutaml/model"

module PubidNew
  module Iec
    module Components
      class Publisher < Lutaml::Model::Serializable
        PUBLISHERS = {
          'IEC' => 'International Electrotechnical Commission',
          'ISO/IEC' => 'ISO/IEC Joint Technical Committee',
          'CISPR' => 'International Special Committee on Radio Interference',
          'IECEE' => 'IEC System of Conformity Assessment Schemes for Electrotechnical Equipment and Components',
          'IECEx' => 'IEC System for Certification to Standards Relating to Equipment for Use in Explosive Atmospheres',
          'IECQ' => 'IEC Quality Assessment System for Electronic Components'
        }.freeze

        attribute :body, :string

        def validate!
          unless PUBLISHERS.key?(body)
            raise ArgumentError, "Unknown IEC publisher: #{body}"
          end
        end

        def to_s
          body
        end

        def full_name
          PUBLISHERS[body]
        end
      end
    end
  end
end