# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### [2.0.0] - 2025-01-16

#### Added

- Comprehensive documentation for all 29 PubID v2 flavors
- Complete TYPED_STAGES registry pattern for all applicable flavors
- Standardized base class hierarchy (SingleIdentifier, SupplementIdentifier)
- Architecture verification script for ensuring consistency across all flavors
- Fixed 6 incomplete flavors (CIE, IDF, ASME, ASTM, CSA, OIML)
- Release checklist for validating v2.0.0 readiness

#### Changed

- Migrated NIST from series_to_class_map to TYPED_STAGES pattern
- Standardized architecture across all flavors with consistent base classes
- Improved supplement recursion support via base_identifier attribute
- All 29 flavors now have complete documentation with identifier class listings
- All flavors now use registry-based architecture via Scheme classes

#### Fixed

- Missing scheme.rb files in CIE, IDF, ASME, ASTM, CSA, OIML
- Missing single_identifier.rb in CIE, IDF
- Missing supplement_identifier.rb in CIE, IDF
- DRY violations in Builder classes across multiple flavors
- Test fixtures for ASTM flavor
- Architecture inconsistencies across 29 flavors

## [0.1.0] - Initial Release

#### Added

- Initial v2 implementation with core architecture
- Three-layer architecture pattern (Parser, Builder, Identifier)
- Registry-based architecture via Scheme classes
- Initial implementation of core flavors (ISO, IEC, IEEE, NIST, etc.)
