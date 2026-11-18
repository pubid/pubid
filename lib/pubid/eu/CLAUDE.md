# EU legal acts (`Pubid::Eu`)

Regulations, directives and decisions of the Official Journal (CELEX sector 3,
type letters R / L / D). Requested by relaton/relaton#44 for the `Relaton::Eu`
flavor, whose `Relaton::Db` cache keys on this pubid.

## Forms

| input | example | `to_s` |
|---|---|---|
| canonical (round-trips) | `EU Regulation 1227/2011` | same |
| Official Journal long form | `Regulation (EU) No 1227/2011`, `Directive 2010/75/EU` | canonical; sets `family` |
| CELEX | `32011R1227`, `CELEX 32011R1227`, `CELEX:32011R1227` | canonical |
| ELI | `http(s)://data.europa.eu/eli/reg/2011/1227[/oj]` | canonical |

`#to_celex` and `#to_eli` give the two official identifiers back. `to_urn`
(`urn:eu:reg:2011:1227`) is pubid-invented: the EU has no URN namespace.

`Pubid.parse` routes only the canonical form (the prefix `EU`). The other
forms do not start with `EU` and do not round-trip, and prefix routing lets
only a prefix owner give a non-exact parse, so call `Pubid::Eu.parse` for
them. relaton queries with the canonical form only.

## The number order is spelling, kept in `number_first`

The order of the two numbers is not derivable from the string:
`Regulation (EC) No 2003/2003` exists, and a pre-2015 number can look like a
year. Before 2015 a regulation printed `<number>/<year>`; directives printed
`<year>/<number>`; **decisions used both** (`Decision No 1082/2013/EU`, an
act of the Parliament and the Council, and `Decision 2010/87/EU`, a
Commission act). From 2015 every act prints `<year>/<number>`.

- **Render rule** (`Identifier#default_number_first?`): a regulation with a
  year before 2015 prints `<number>/<year>`; everything else prints
  `<year>/<number>`. The builder stores `number_first` **only when the input
  order differs from this rule** (`EU Decision 1082/2013` → `true`), so a
  normal index row carries no flag. It is `equality_ignored` and a URN facet:
  the order is spelling, and `EU Decision 1082/2013` equals `32013D1082`.
- **Parse rule** (`Builder.number_first_for`), for every form: `No` marks
  `<number>/<year>` (the Official Journal convention, exact for the long
  form). Without `No`, a value is a plausible year when it has 4 digits in
  1952..2099; one plausible value is the year; with two, a first value from
  2015 is the year, else a regulation reads `<number>/<year>` and another act
  `<year>/<number>`; none raises `Pubid::Errors::ParseError` (from the
  builder, not the grammar). The long form uses the same rule, so
  `to_s(with_publisher: false)` (`Regulation 1227/2011`) parses back.
- **Two acts can share one plain print**: `32015R2014` and `32014R2015` both
  print `2015/2014`. The renderer asks the parse rule how the plain pair
  reads back; when that is another act it prints `EU Regulation No 2015/2014`
  instead. So `parse(id.to_s) == id` for every act, in both orders and without
  the publisher; `spec/pubid/eu/identifier_spec.rb` sweeps a year × number
  grid to lock it. A canonical input always reads back as itself, so it
  never gains a `No`.
- CELEX and ELI years are checked against the same range, and a number of
  0 is rejected. The bracketed family and the suffixed one are separate
  captures; two different ones (`Regulation (EU) No 1227/2011/EC`) raise.

## Identity and matching

Identity is the leaf class, `date` (year) and `number` (leading CELEX zeros
stripped). `family` is part of identity but nil on a canonical reference, so
`EU Regulation 1227/2011 === parse("Regulation (EU) No 1227/2011")` is true
(the default SubsetMatch wildcard), and the reverse is false. Every reference
states the year, so the `partial_ref_spec` entry is `omits: []`.

## Known gaps

- Two-digit years (`Directive 95/46/EC`, `Regulation (EEC) No 1408/71`) are
  rejected. They need a century rule, and relaton did not ask for them.
- Joint families (`(EU, Euratom)`) and the CELEX suffixes `(01)` for colliding
  numbers are not parsed.
- The author words of the Official Journal title (`Commission Implementing
  Regulation (EU) 2019/947`, `Council Directive …`) are not parsed; strip
  them first. They name no other act, so they would not be identity.
- Other CELEX sectors (treaties, case law) are out of scope.

## The grammar is baked here ahead of pubid-grammar

`data/parg/eu.json` was compiled in this repo at parsanol **1.5.1.0** (the
Gemfile pin), because `pubid-grammar` had no `grammars/eu.parg` yet. Hand-off
`pubid__pubid-grammar__eu-flavor-grammar` carries the source. To change the
grammar, extract the source with `jq -j .source data/parg/eu.json`, edit,
then:

```bash
bundle exec parsanol parg compile eu.parg -o data/parg/eu.json
bundle exec parsanol parg test data/parg/eu.json
```

Use raw `"/"` and `" "` literals, not `slash`/`space` rule references: a rule
reference makes a tree node, and the alternatives then warn about duplicate
`slash` subtrees (the same note sits in the UN grammar).
