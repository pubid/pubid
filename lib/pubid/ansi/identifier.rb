# frozen_string_literal: true

module Pubid
  module Ansi
    # Base ANSI identifier class
    class Identifier < ::Pubid::Identifier
      # `number`/`part`/`subpart` are declared here rather than inherited as a
      # Components::Code: ANSI stores a bare string in every one of them.
      # Declaring on this class is safe because its body lives in this one file
      # and is never reopened, so every subclass body opens after it has run
      # (lutaml deep-dups the parent attribute table at class-definition time).
      attribute :number, :string
      attribute :part, :string
      attribute :subpart, :string

      # How the input joined the year to the number: "-" for the
      # "ANSI X9.62-2005" spelling, nil for the colon of "ANSI/ISO 9899:1990".
      # Spelling only, so `==`, `hash` and `===` skip it (relaton#45).
      attribute :date_separator, :string
      equality_ignored :date_separator

      # How the input joined the publisher group to the number: "-" for the
      # "ANSI/ISA-5.1-2009" spelling, nil for the space of "ANSI/ISA 5.1".
      # Spelling only, so `==`, `hash` and `===` skip it.
      attribute :number_separator, :string
      equality_ignored :number_separator

      # The revision letter of "ANSI/TIA-568.2-D". It names a different
      # document, so it is identity; `#revision_of?` reads it.
      attribute :revision, :string

      def self.parse(string)
        unless string.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if string.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        string = ::Pubid.utf8_input(string)

        parsed = Pubid::Parg::Model.bound(:ansi, string)
        Pubid::Ansi::Builder.new.build(parsed)
      end

      # The revision is identity, so it reaches the slug too: "568.2-C" and
      # "568.2-D" must not share a filename.
      def mr_number_with_part
        num = super
        num && mr_join(num, revision&.downcase)
      end

      # The separator belongs to the year: drop it with the year, so a
      # year-less copy carries no orphan spelling flag in its hash.
      def exclude(*args)
        result = super
        if args.include?(:year) || args.include?(:date)
          result.date_separator = nil
        end
        result
      end
    end
  end
end
