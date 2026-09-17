# frozen_string_literal: true

require "spec_helper"

# A component-typed attribute must default to a component, never to a raw
# scalar. pubid#383: `Evs::Identifiers::NationalAdoption` declared
# `attribute :type, Components::Type, default: -> { self.class.type[:key] }`,
# so the default was the Symbol :evs_en. `to_hash` drops a default-valued
# attribute, and `from_hash` then finds no key, resolves the default and casts
# the Symbol into the component. lutaml calls `key?` on the Symbol and raises
# InvalidFormatError. `to_s`, `to_urn` and `to_hash` all stay correct, so only
# a deserialization sees the defect.
module ComponentAttributeDefaultSpec
  # Classes that still have a raw default. Value is the reason, shown in the
  # pending output. A pending example that starts to pass FAILS: that red is
  # the signal to delete its entry. Empty today - the EVS and IDF defaults
  # this check was written for are fixed.
  PENDING_RAW_DEFAULTS = {}.freeze

  module_function

  # Force-load every identifier class, including the ones nested a level
  # deeper than `Identifiers::` (IEEE `Nesc::`, `Ire::`).
  def load_identifier_classes(namespace, depth = 0)
    return if depth > 2

    namespace.constants.each do |const|
      value = begin
        namespace.const_get(const)
      rescue StandardError, ScriptError
        next
      end
      load_identifier_classes(value, depth + 1) if value.is_a?(Module)
    end
  end

  # Every named identifier class of every registered flavor, loaded once.
  def identifier_classes
    @identifier_classes ||= begin
      Pubid.eager_load_flavors!
      Pubid::Registry.flavor_names.each do |flavor|
        load_identifier_classes(Pubid::Registry.get(flavor))
      end
      ObjectSpace.each_object(Class)
        .select { |klass| klass < Pubid::Identifier && klass.name }
        .sort_by(&:name)
    end
  end

  def component_type(attr, register)
    type = attr.type(register)
    type if type.is_a?(Class) && type < Lutaml::Model::Serializable
  end

  def acceptable_default?(value, type)
    return true if value.nil? || Lutaml::Model::Utils.uninitialized?(value)

    return true if value.is_a?(Hash)

    Array(value).all? { |item| item.is_a?(type) || item.is_a?(Hash) }
  end

  # "Class#attribute" for every raw default on a component attribute. An
  # attribute whose type or default cannot be resolved is reported too, so a
  # blind spot of this check is visible and never passes silently.
  def raw_defaults(klass)
    register = Lutaml::Model::Config.default_register
    instance = klass.allocate
    klass.attributes.filter_map do |name, attr|
      suffix = raw_default(attr, register, instance)
      "#{klass.name}##{name}#{suffix}" if suffix
    end
  end

  # nil when the default is acceptable, else a suffix for the report.
  def raw_default(attr, register, instance)
    type = component_type(attr, register)
    return unless type

    value = attr.default_value(register, instance)
    "" unless acceptable_default?(value, type)
  rescue StandardError => e
    " (#{e.class}: #{e.message})"
  end
end

RSpec.describe "Component attribute defaults" do
  let(:classes) { ComponentAttributeDefaultSpec.identifier_classes }
  let(:pending_names) { ComponentAttributeDefaultSpec::PENDING_RAW_DEFAULTS.keys }

  it "finds the identifier classes to check" do
    expect(classes.size).to be > 100
  end

  it "has no pending entry for an unknown class" do
    expect(pending_names - classes.map(&:name)).to eq([])
  end

  it "gives every component attribute a component default" do
    offenders = classes
      .reject { |klass| pending_names.include?(klass.name) }
      .flat_map { |klass| ComponentAttributeDefaultSpec.raw_defaults(klass) }

    expect(offenders).to eq([])
  end

  ComponentAttributeDefaultSpec::PENDING_RAW_DEFAULTS.each do |name, reason|
    it "gives #{name} a component default" do
      pending(reason)

      klass = Object.const_get(name)
      expect(ComponentAttributeDefaultSpec.raw_defaults(klass)).to eq([])
    end
  end
end
