# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# Cross-flavor contract for what `parse` does with input it cannot turn into an
# identifier. Consumers rescue by CLASS, so the class is the contract:
# relaton-cli rescues `Parslet::ParseFailed` (command.rb,
# subcommand_collection.rb) to print `"<code>" is not a recognized standards
# identifier`, and nothing else on that path rescues — so a flavor that
# re-wrapped the parser's error as a bare RuntimeError handed the user a raw
# Ruby backtrace instead of a sentence.
#
# Four rules, locked here for every registered flavor:
#
#   unparseable string -> Parslet::ParseFailed
#   over-long string   -> ArgumentError (a DIFFERENT failure: the ReDoS guard,
#                         which must fire before the input reaches a regex)
#   non-String (nil)   -> ArgumentError (not the NoMethodError that reaching
#                         `.length` on nil used to produce)
#   anything           -> never nil
#
# This is registry-driven rather than table-driven, mirroring
# spec/pubid/parse_interface_spec.rb: the junk strings below are rejected by
# every flavor, so there is no per-flavor entry to add — and therefore none to
# go stale — when a flavor is added.
RSpec.describe "parse failure contract (cross-flavor)" do
  # Deliberately unlike any identifier in any flavor. Note a bare single token
  # ("zzzz") would NOT do: adobe and iana accept any slug by design, so their
  # grammar rightly takes one.
  UNPARSABLE = [
    "@@@ not an identifier @@@",
    "!!! ### ???",
  ].freeze

  OVERLONG = "A#{'9' * Pubid::MAX_INPUT_LENGTH}".freeze

  it "covers every registered flavor" do
    expect(Pubid::Registry.flavor_names).not_to be_empty
    expect(Pubid::Registry.flavor_names).to include("iso", "iec", "3gpp", "w3c")
  end

  Pubid::Registry.flavor_names.each do |flavor_name|
    context flavor_name do
      let(:mod) { Pubid::Registry.get(flavor_name) }
      let(:identifier_class) { mod.const_get(:Identifier) }

      # Both entry points, because relaton holds a flavor's Identifier class
      # directly (`pubid_class:`) and never sees the module method.
      def each_entry_point(mod, klass)
        yield "module-level parse", mod
        yield "Identifier.parse", klass
      end

      UNPARSABLE.each do |bad|
        it "raises Parslet::ParseFailed for #{bad.inspect}" do
          each_entry_point(mod, identifier_class) do |label, receiver|
            expect { receiver.parse(bad) }
              .to raise_error(Parslet::ParseFailed),
                  "#{flavor_name} #{label} did not raise " \
                  "Parslet::ParseFailed for #{bad.inspect}"
          end
        end

        # The class pubid OWNS. The assertion above is the backward-compatible
        # half of the same raise: `Pubid::Errors::ParseError` inherits
        # `Parslet::ParseFailed`, so both hold at once and a consumer can
        # rescue either.
        it "raises Pubid::Errors::ParseError for #{bad.inspect}" do
          each_entry_point(mod, identifier_class) do |label, receiver|
            expect { receiver.parse(bad) }
              .to raise_error(Pubid::Errors::ParseError),
                  "#{flavor_name} #{label} did not raise " \
                  "Pubid::Errors::ParseError for #{bad.inspect}"

            expect { receiver.parse(bad) }
              .to raise_error(Pubid::Errors::Error),
                  "#{flavor_name} #{label} raised a failure outside the " \
                  "Pubid::Errors::Error marker for #{bad.inspect}"
          end
        end

        it "never returns nil for #{bad.inspect}" do
          each_entry_point(mod, identifier_class) do |label, receiver|
            result = begin
              receiver.parse(bad)
            rescue Parslet::ParseFailed
              :raised
            end
            expect(result).not_to be_nil,
                                  "#{flavor_name} #{label} returned nil for " \
                                  "#{bad.inspect} instead of raising"
          end
        end
      end

      # The length guard is a different failure from an unparseable string, and
      # it must keep its own class: it is the CodeQL rb/polynomial-redos
      # barrier and has to fire BEFORE the input reaches a normalization regex.
      it "raises ArgumentError for over-long input" do
        each_entry_point(mod, identifier_class) do |label, receiver|
          expect { receiver.parse(OVERLONG) }
            .to raise_error(ArgumentError, /maximum length/),
                "#{flavor_name} #{label} has no input-length guard"
        end
      end

      it "raises ArgumentError for nil" do
        each_entry_point(mod, identifier_class) do |label, receiver|
          expect { receiver.parse(nil) }
            .to raise_error(ArgumentError, /must be a String/),
                "#{flavor_name} #{label} let nil reach the parser"
        end
      end

      # Same raise as the two above, seen through the class pubid owns:
      # `Pubid::Errors::InvalidInputError` inherits `ArgumentError`.
      it "raises Pubid::Errors::InvalidInputError for bad input" do
        each_entry_point(mod, identifier_class) do |label, receiver|
          [OVERLONG, nil].each do |bad_input|
            expect { receiver.parse(bad_input) }
              .to raise_error(Pubid::Errors::InvalidInputError),
                  "#{flavor_name} #{label} did not raise " \
                  "Pubid::Errors::InvalidInputError for #{bad_input.class}"
          end
        end
      end
    end
  end

  # A flavor that hands a string to ANOTHER flavor's parser used to leak that
  # flavor's error class, so one `parse` raised two different classes depending
  # on its input. These pin the specific routes; the generic loop above cannot
  # reach them, because its junk never looks like the delegate's flavor.
  describe "cross-flavor delegation raises the delegate's failure uniformly" do
    it "Pubid::Iso.parse routes an ITU-shaped string through the MR parser" do
      expect { Pubid::Iso.parse("ITU-T G.711") }
        .to raise_error(Parslet::ParseFailed)
    end

    it "Pubid::Bsi.parse delegates an IEC CSV form to Pubid::Iec" do
      expect { Pubid::Bsi.parse("IEC 99999999 CSV zz") }
        .to raise_error(Parslet::ParseFailed)
    end

    it "Pubid::Csa.parse delegates an adopted ISO form to Pubid::Iso" do
      expect { Pubid::Csa.parse("CAN/CSA-ISO ###") }
        .to raise_error(Parslet::ParseFailed)
    end
  end

  # `Pubid.parse` is the top-level entry and never routes a human-readable
  # string to a flavor at all — it handles URNs and MR strings and otherwise
  # says so. It still owes the caller the same two input guards, and it is not
  # reached by the per-flavor loop above.
  describe "Pubid.parse (top-level entry)" do
    it "raises ArgumentError for nil" do
      expect { Pubid.parse(nil) }
        .to raise_error(ArgumentError, /must be a String/)
    end

    it "raises ArgumentError for over-long input" do
      expect { Pubid.parse(OVERLONG) }
        .to raise_error(ArgumentError, /maximum length/)
    end

    it "still parses a URN" do
      expect(Pubid.parse("urn:iso:std:iso:9001:ed-5").to_s).to eq("ISO 9001")
    end
  end

  # The two flavors whose grammar is a catch-all slug take any single token by
  # design (lib/pubid/iana/CLAUDE.md). Pin that, so the UNPARSABLE strings above
  # are never "simplified" to a bare word that these two would accept — which
  # would make their examples pass for the wrong reason.
  describe "slug grammars accept a bare token by design" do
    it "IANA takes a bare registry slug" do
      expect(Pubid::Iana.parse("zzzz").to_s).to eq("IANA zzzz")
    end

    it "Adobe takes a bare publication slug" do
      expect(Pubid::Adobe.parse("zzzz").to_s).to eq("Adobe Publication zzzz")
    end
  end
end
