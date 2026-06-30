# frozen_string_literal: true

# Pubid::Itu::Identifier is the ITU base class (a real Pubid::Identifier
# subclass); its body, `.parse`, and the Identifiers::Base back-compat alias
# live in identifiers/base.rb. This file just ensures it is loaded.
require_relative "identifiers/base"
