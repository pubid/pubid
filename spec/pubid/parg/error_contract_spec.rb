# frozen_string_literal: true

require "spec_helper"
require "parsanol/parg"

# The parg engine's errors must never escape pubid as themselves: the
# uniform error contract makes `rescue Pubid::Errors::Error` exhaustive
# (spec/pubid/errors_spec.rb), and relaton's exact_parse guard rescues
# exactly that plus ArgumentError. Issue #646 broke it — parsanol 1.3.122's
# binding check raises `Parsanol::PARG::BindError`, a class unrelated to
# `Parsanol::ParseFailed`, and a grammar/binding failure carried it raw out
# of `Pubid.parse`, past every consumer guard.
#
# The live repro is a bsi testsuite row the grammar accepts but cannot bind
# (parsanol-ruby#427, the bsi raw-coverage residual): the wrap is pinned
# against that input, and structurally by the ENGINE_ERRORS constant the
# three choke points rescue through — the same tripwire shape as
# spec/pubid/evs/from_hash_spec.rb.
RSpec.describe Pubid::Parg do
  describe "ENGINE_ERRORS" do
    it "lists the reference engine's parse failure" do
      expect(described_class::ENGINE_ERRORS).to include(Parsanol::ParseFailed)
    end

    it "lists the PARG artifact/binding failure family" do
      expect(described_class::ENGINE_ERRORS).to include(Parsanol::PARG::Error)
    end

    it "keeps the choke points rescuing through the constant" do
      # lib/pubid/parg/model.rb (bound + parse) and lib/pubid/parg/backend.rb
      # (parse) — the three call sites that run an artifact against an input.
      model = File.read(File.expand_path("../../../lib/pubid/parg/model.rb", 
                                         __dir__))
      backend = File.read(File.expand_path(
                            "../../../lib/pubid/parg/backend.rb", __dir__
                          ))

      expect(model.scan("rescue *ENGINE_ERRORS").size).to eq(2)
      expect(backend.scan("rescue *ENGINE_ERRORS").size).to eq(1)
    end

    it "would catch a BindError through the PARG family" do
      # The class #646 leaked, shipped with the loud-loss binding check
      # (parsanol 1.3.122 — the gemspec floor). The rescue matches by class
      # ancestry: a BindError instance must satisfy an entry of the list, or
      # it escapes again.
      expect(Parsanol::PARG::BindError).to be < Parsanol::PARG::Error
      expect(described_class::ENGINE_ERRORS.any? do |klass|
        klass >= Parsanol::PARG::BindError
      end).to be(true)
    end
  end

  describe "a binding failure surfacing through pubid" do
    # The known live BindError repro (parsanol-ruby#427): the bsi grammar
    # accepts the bundled form but its `part` capture reaches the bound map
    # nowhere, and the engine raises PARG::BindError mid-bind.
    subject(:error) do
      Pubid::Bsi.parse("BS 9113 N001 to 004:1973")
    rescue StandardError => e
      e
    end

    it "raises Pubid::Errors::ParseError, not the engine's BindError" do
      expect(error).to be_a(Pubid::Errors::ParseError)
      expect(error).not_to be_a(Parsanol::PARG::BindError)
    end

    it "is caught by the marker, like every pubid failure" do
      expect(error).to be_a(Pubid::Errors::Error)
    end

    it "chains the engine's BindError as the Ruby cause" do
      expect(error.cause).to be_a(Parsanol::PARG::BindError)
    end

    it "carries the input and the flavor" do
      expect(error.input).to eq("BS 9113 N001 to 004:1973")
      expect(error.flavor).to eq("bsi")
    end
  end

  describe "Pubid.parse never leaks a parser-internal exception" do
    # Routing-level: a flavor whose engine raises a binding failure must
    # hand the caller a pubid error, whatever input triggered it.
    it "surfaces the hostile bundled input inside the pubid hierarchy" do
      expect { Pubid.parse("BS 9113 N001 to 004:1973") }
        .to raise_error(Pubid::Errors::Error)
      expect { Pubid.parse("BS 9113 N001 to 004:1973") }
        .not_to raise_error(Parsanol::ParseFailed)
      expect { Pubid.parse("BS 9113 N001 to 004:1973") }
        .not_to raise_error(Parsanol::PARG::Error)
    end

    # The issue's original repro, parsing clean on the re-vendored
    # artifact (#649). Pinned as a contract: should a JIS year form ever
    # fail again, it may only fail as a pubid error.
    it "keeps JIS year forms inside the hierarchy whether they parse or fail" do
      expect { Pubid.parse("JIS Z 8301:2019") }
        .not_to raise_error(Parsanol::ParseFailed)
      expect { Pubid.parse("JIS Z 8301:2019") }
        .not_to raise_error(Parsanol::PARG::Error)
      expect { Pubid.parse("JIS Z 8301:2019") }
        .not_to raise_error(Parsanol::GrammarError)
    end
  end
end
