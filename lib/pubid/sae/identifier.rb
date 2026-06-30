# frozen_string_literal: true

# Pubid::Sae::Identifier is the SAE base class (a real Pubid::Identifier
# subclass); its body, `.parse`, and the Identifiers::Base back-compat alias
# live in identifiers/base.rb. This file just ensures it is loaded.
require_relative "identifiers/base"
