# IETF Identifier Patterns

IETF identifiers

## Entry Point

```ruby
require 'pubid/ietf'
id = Pubid::Ietf.parse("...")
```

## Identifier Types

### Base

**Class:** `Pubid::Ietf::Identifiers::Base`

### Bcp

**Class:** `Pubid::Ietf::Identifiers::Bcp`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BCP" | Best Current Practice | :published |  |

### Fyi

**Class:** `Pubid::Ietf::Identifiers::Fyi`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "FYI" | For Your Information | :published |  |

### Internet Draft

**Class:** `Pubid::Ietf::Identifiers::InternetDraft`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "I-D", "Internet-Draft" | Internet-Draft | :draft |  |

### Rfc

**Class:** `Pubid::Ietf::Identifiers::Rfc`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "RFC" | Request for Comments | :published |  |

### Serialization

**Class:** `Pubid::Ietf::Identifiers::Serialization`

### Std

**Class:** `Pubid::Ietf::Identifiers::Std`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "STD" | Internet Standard | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
