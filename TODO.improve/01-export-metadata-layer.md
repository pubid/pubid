# Task 1: Metadata Export Layer (Ruby)

## Goal
Create an OOP metadata extraction layer that exports library identifier metadata as JSON for website consumption, without modifying any existing API.

## Design Principles
- **Open/Closed**: New `Exporter` module; no changes to existing class signatures
- **Encapsulation**: Extract through public APIs (`Scheme.identifiers`, `def self.type`, `TYPED_STAGES`) — never reach into parser internals
- **Strategy Pattern**: Per-flavor extraction strategies to handle the 5 scheme implementation patterns

## Architecture

```
lib/pubid/export/
├── exporter.rb              # Top-level orchestrator
├── flavor_exporter.rb       # Base class for flavor extraction
├── scheme_exporter.rb       # For Scheme-based flavors (ISO, IEC, BSI, CEN, etc.)
├── data_class_exporter.rb   # For Lutaml::Model data class flavors (ETSI, Plateau)
├── simple_exporter.rb       # For minimal flavors (ANSI, OIML, CSA, etc.)
└── result.rb                # Structured result object (identifier type, stages, examples)
```

### Strategy Pattern
Flavors fall into categories based on their Scheme pattern:

1. **Scheme-based with identifiers class method** (ISO, IEC, ASTM, ASHRAE, ASME, CCSDS, CIE, CSA, JIS, JCGM, OIML, IDF, API, SAE)
   - Use `Scheme.identifiers` or `Scheme.instance.identifiers`
   - Extract `def self.type`, `TYPED_STAGES`, `define_metadata`

2. **Scheme-based with instance identifiers** (BSI, CEN)
   - Use `TYPED_STAGES_REGISTRY` on the Scheme class
   - Extract typed stages from registry

3. **Non-standard Scheme** (NIST)
   - Use `Scheme.identifiers` + per-class `typed_stages` method
   - NIST identifier classes define typed stages differently

4. **Data class Scheme** (ETSI, Plateau)
   - Use `Lutaml::Model::Serializable` attributes
   - No TYPED_STAGES, simpler structure

5. **Minimal Scheme** (ANSI, AMCA, IEEE, ITU)
   - Simple identifier lists or custom patterns

### Fixture Example Extraction
Read `spec/fixtures/{flavor}/identifiers/pass/*.txt` files, parse the `!Type input!expected` format, and collect real-world examples per type.

## Output Format (JSON)
```json
{
  "iso": {
    "identifier_types": [
      {
        "key": "is",
        "title": "International Standard",
        "short": null,
        "abbr": ["", "IS"],
        "typed_stages": [
          { "code": "isdp", "stage_code": "dp", "type_code": "is", "abbr": ["DP"], "name": "Draft Proposal", "harmonized_stages": [] }
        ],
        "examples": ["ISO 9001:2015", "ISO/IEC 17031-1:2020"]
      }
    ],
    "attributes": ["number", "part", "date", "edition", ...]
  }
}
```

## Files to Create
| File | Purpose |
|------|---------|
| `lib/pubid/export/exporter.rb` | Orchestrator: iterates flavors, delegates to strategy |
| `lib/pubid/export/flavor_exporter.rb` | Abstract base with `export()` interface |
| `lib/pubid/export/scheme_exporter.rb` | Strategy for Scheme-based flavors |
| `lib/pubid/export/data_class_exporter.rb` | Strategy for Lutaml data class flavors |
| `lib/pubid/export/simple_exporter.rb` | Strategy for minimal flavors |
| `lib/pubid/export/result.rb` | Value object for extraction results |
| `lib/pubid/export.rb` | Module entry point |
| `lib/tasks/export.rake` | Rake task: `rake export:website_data` |

## Rake Task
```ruby
# lib/tasks/export.rake
namespace :export do
  desc "Export library metadata as JSON for the website"
  task :website_data do
    require "pubid/export"
    data = Pubid::Export::Exporter.export_all
    File.write("website-data.json", JSON.pretty_generate(data))
    puts "Exported #{data.keys.size} flavors to website-data.json"
  end
end
```

## Constraints
- No modification to any existing `parse`, `to_s`, `to_urn`, `to_h` signatures
- No modification to existing Scheme class interfaces
- Additions only: new module, new rake task, new classes
