# API Identifier Patterns

API (American Petroleum Institute)

## Entry Point

```ruby
require 'pubid/api'
id = Pubid::Api.parse("...")
```

## Identifier Types

### Base

**Class:** `Pubid::Api::Identifiers::Base`

### Bulletin

**Class:** `Pubid::Api::Identifiers::Bulletin`

### Continuous Operations Standard

**Class:** `Pubid::Api::Identifiers::ContinuousOperationsStandard`

### Mpms

**Class:** `Pubid::Api::Identifiers::Mpms`

### Publication

**Class:** `Pubid::Api::Identifiers::Publication`

### Recommended Practice

**Class:** `Pubid::Api::Identifiers::RecommendedPractice`

### Specification

**Class:** `Pubid::Api::Identifiers::Specification`

### Standard

**Class:** `Pubid::Api::Identifiers::Standard`

### Technical Report

**Class:** `Pubid::Api::Identifiers::TechnicalReport`

### Typeless Standard

**Class:** `Pubid::Api::Identifiers::TypelessStandard`

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
