  module Pubid
    module EtsiPfs
      class Builder
        def self.build(parsed_data)
          new.build(parsed_data)
        end

        def build(data)
          Identifiers::Standard.new(
          type: data[:type],
          number: data[:number],
          minor: data[:minor],
          parts: data[:parts],
          supplements: data[:supplements],
          version: data[:version],
          edition: data[:edition],
          year: data[:year],
          month: data[:month],
          )
        end
      end
    end
  end

  Pubid::EtsiPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
