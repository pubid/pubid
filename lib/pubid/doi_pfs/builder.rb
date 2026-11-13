  module Pubid
    module DoiPfs
      class Builder
        def self.build(parsed_data)
          new.build(parsed_data)
        end

        def build(data)
          Identifiers::Resource.new(
          prefix: data[:prefix],
          suffix: data[:suffix],
          )
        end
      end
    end
  end

  Pubid::DoiPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
