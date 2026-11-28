# frozen_string_literal: true

require "spec_helper"
require "set"

Pubid.eager_load_flavors!

# Issue #803: the dispatch loop keeps the failed parse's message, input and
# flavor strings plus the failure position as an Integer — never the error
# object itself. Ruby chains the engine's own failure (a
# +Parsanol::ParseFailed+) as a raised error's cause, and that chain holds
# the {Parsanol::Source}: the subject string, a StringScanner, a regex cache
# and the engine's slice and position pools. The plateau campaign measured
# millions of engine failures alive across long compiles; parsanol-ruby#123
# cut the retention on the engine side, and the dispatcher must not hold the
# chain either.
RSpec.describe "the dispatch failure record holds no engine error (#803)" do
  # Collection members / exception causes one link below +obj+.
  def children_of(obj)
    case obj
    when Array then obj
    when Hash then obj.keys + obj.values
    when Struct then obj.to_a
    when Exception then [obj.cause].compact
    else []
    end
  end

  # Every object reachable from +obj+ through instance variables, collection
  # members and exception causes (depth-capped, cycle-safe).
  def reachable_from(obj, seen = Set.new, depth = 0, &block)
    return unless obj.is_a?(Object) && !obj.is_a?(Module)
    return if depth > 8 || seen.include?(obj.object_id)

    seen << obj.object_id
    yield(obj)
    reachable_from_ivars(obj, seen, depth, &block)
    children_of(obj).each do |child|
      reachable_from(child, seen, depth + 1, &block)
    end
  end

  # The instance-variable links of +obj+.
  def reachable_from_ivars(obj, seen, depth, &block)
    obj.instance_variables.each do |iv|
      reachable_from(obj.instance_variable_get(iv), seen, depth + 1, &block)
    end
  end

  def dispatch_failure(input)
    Pubid.parse(input)
  rescue Pubid::Errors::ParseError => e
    e
  end

  RSpec::Matchers.define :retain_no_engine_state do
    match do |error|
      forbidden = [MatchData, Parsanol::Source, Parsanol::ParseFailed,
                   Parsanol::Cause]
      found = []
      reachable_from(error) do |node|
        found << node.class if forbidden.include?(node.class)
      end
      @found = found
      found.empty?
    end

    failure_message do
      "the raised error still retains engine state: #{@found.uniq.inspect}"
    end
  end

  describe "a rejection accumulated across the full dispatch order" do
    subject(:error) { dispatch_failure("iec.60050") }

    it "raises Pubid::Errors::ParseError" do
      expect(error).to be_a(Pubid::Errors::ParseError)
    end

    it "chains no engine failure as the Ruby cause" do
      expect(error.cause).to be_nil
    end

    it "holds no MatchData, Source, ParseFailed or Cause anywhere" do
      expect(error).to retain_no_engine_state
    end

    it "carries the failure position as an Integer" do
      expect(error.position).to be_an(Integer)
    end

    it "carries only strings and the position in its instance variables" do
      expect(error.instance_variables.map do |iv|
        error.instance_variable_get(iv)
      end)
        .to all(be_a(String).or(be_nil).or(be_an(Integer)))
    end
  end

  describe "a sole-owner rejection (fail-fast path)" do
    subject(:error) { dispatch_failure("3GPP") }

    it "holds the owning flavor's message, input and flavor" do
      direct =
        begin
          Pubid::Tgpp.parse("3GPP")
        rescue Pubid::Errors::ParseError => e
          e
        end

      expect(error.message).to eq(direct.message)
      expect(error.input).to eq(direct.input)
      expect(error.flavor).to eq(direct.flavor)
    end

    it "chains no engine failure as the Ruby cause" do
      expect(error.cause).to be_nil
    end

    it "holds no engine state anywhere" do
      expect(error).to retain_no_engine_state
    end
  end

  describe "a synthetic rejection without an engine cause" do
    # CSA rejects its non-standard products before the grammar runs; the
    # raise is not inside a rescue, so no engine failure is chained.
    subject(:error) { dispatch_failure("CSA Learning something") }

    it "chains no engine failure" do
      expect(error.cause).to be_nil
    end

    it "leaves the position nil rather than inventing one" do
      expect(error.position).to be_nil
    end

    it "holds no engine state anywhere" do
      expect(error).to retain_no_engine_state
    end
  end

  describe "the ParseError position field" do
    it "defaults to nil so existing constructors are unchanged" do
      expect(Pubid::Errors::ParseError.new("nope").position).to be_nil
      expect(Pubid::Errors::ParseError.new("nope", nil).position).to be_nil
    end

    it "accepts an explicitly extracted position" do
      error = Pubid::Errors::ParseError.new(
        "nope", nil, input: "x", flavor: "iso", position: 4
      )
      expect(error.position).to eq(4)
    end
  end
end
