# Task 05: Auto-Generation Rake Task for Pattern Docs

## Status: DONE

## Goal

Create `lib/tasks/docs.rake` with a `rake docs:patterns` task that auto-generates identifier pattern reference documentation from code and test fixtures. This ensures docs stay in sync with code changes.

## Task Requirements

### `rake docs:patterns`

For each flavor in `lib/pubid/`:
1. List identifier types from `identifiers/` directory
2. Extract `TYPED_STAGES` constants, stage codes, abbreviations
3. Sample up to 5 passing fixtures from `spec/fixtures/{flavor}/pass/`
4. Generate markdown with pattern tables
5. Generate cross-flavor comparison table for README

### Output

- `docs/identifier-patterns/{flavor}.md` for each flavor
- `docs/identifier-patterns/README.md` with cross-flavor comparison table

### Data Sources

| Data | Source |
|------|--------|
| Identifier types | `lib/pubid/{flavor}/identifiers/*.rb` (class names) |
| Typed stages | `TYPED_STAGES` constants in each identifier class |
| Real examples | `spec/fixtures/{flavor}/pass/*.txt` (sampled) |
| Parser grammar | `lib/pubid/{flavor}/parser.rb` (pattern extraction) |
| URN formats | `lib/pubid/{flavor}/urn_generator.rb` |
| Update codes | `data/{flavor}/update_codes.yaml` |

## Implementation

```ruby
# lib/tasks/docs.rake
namespace :docs do
  desc "Generate identifier pattern reference docs"
  task :patterns do
    flavors = Dir["lib/pubid/*/"].map { |d| File.basename(d) } - ["core"]

    flavors.each do |flavor|
      generator = PatternDocGenerator.new(flavor)
      generator.generate
    end

    # Generate cross-flavor comparison table
    CrossFlavorTable.generate(flavors)
  end
end
```

## Files to Create

- `lib/tasks/docs.rake` — rake task definitions
- `lib/pubid/core/pattern_doc_generator.rb` — generation logic (reusable across flavors)

## Acceptance Criteria

- `bundle exec rake docs:patterns` generates all pattern docs
- Generated docs are valid markdown
- Cross-flavor comparison table is accurate
- Task is idempotent (re-running produces same output)
- Task completes in under 60 seconds
