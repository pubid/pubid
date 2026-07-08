# frozen_string_literal: true

module Pubid
  # Mixin providing the uniform, static +prefixes+ class method that every
  # registered flavor exposes. relaton uses this to build a global prefix
  # register that routes a printed reference string (e.g. +"DD 1234"+,
  # +"ISO/IEC 8802"+) to the flavor(s) that own it.
  #
  # A flavor +extend+s this module and defines a frozen +PREFIXES+ array holding
  # only *its own* leading tokens. Joint / co-publication tokens are injected
  # centrally from {Pubid::JOINT_PREFIXES} so that a co-published prefix
  # (e.g. +"ISO/IEC"+) is listed symmetrically by every co-publisher without
  # being duplicated by hand in two files.
  #
  # == Inclusion policy
  # +prefixes+ returns the set of *leading identifier prefix tokens* — the
  # tokens a printed identifier can start with such that the string belongs to
  # this SDO. Concretely it INCLUDES:
  # * publisher prefixes (e.g. +ISO+, +IEC+, +NIST+, +NBS+, +BS+, +BSI+);
  # * leading series/type tokens that can *begin* a printed reference on their
  #   own (e.g. BSI +DD+/+PD+, NIST +FIPS+/+SP+);
  # * joint / co-publication forms (e.g. +ISO/IEC+, +ISO/IEC/IEEE+).
  # It EXCLUDES:
  # * pure sub-series that never appear without a publisher prefix;
  # * dangerously-ambiguous single letters (e.g. BSI aerospace +A+/+B+/+C+),
  #   which would cause false routing.
  module PrefixesSupport
    # The static set of leading prefix tokens this flavor recognizes.
    #
    # Static: callable without parsing any identifier string. Strings are
    # returned in canonical case exactly as printed (e.g. +"BS EN ISO"+,
    # +"ISO/IEC"+); consumers fold case themselves.
    #
    # @return [Array<String>] frozen, de-duplicated list of prefix tokens
    def prefixes
      own = const_defined?(:PREFIXES) ? const_get(:PREFIXES) : []
      joint = Pubid::JOINT_PREFIXES.fetch(prefix_flavor_key, [])
      (own + joint).uniq.freeze
    end

    # The registry key for this flavor, derived from the module name
    # (e.g. +Pubid::CenCenelec+ => +:cen_cenelec+). Used to look this flavor up
    # in {Pubid::JOINT_PREFIXES} and to label it in {Pubid.prefix_flavors}.
    #
    # @return [Symbol]
    def prefix_flavor_key
      name.split("::").last
        .gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase.to_sym
    end
  end
end
