# Versioning

Kito uses two versioning tracks side by side. Understanding which track a
version belongs to prevents almost every mistake this scheme could cause.

## Track A — individual kits (SemVer)

Every kit (`KitoCore`, `KitoButtons`, `KitoFields`, `KitoScreens`) versions
itself independently on strict SemVer:

- **MAJOR** — any breaking change to public API. Renaming a token, removing a
  view, changing a required initializer parameter.
- **MINOR** — additive public API. New view, new modifier, new theme token,
  new public initializer parameter with a default.
- **PATCH** — bug fixes, docs, internal refactors that do not touch public
  API or observable behavior.

Kits release on their own schedule. A `KitoButtons` patch does not wait for
`KitoScreens` to be ready.

### The `KitoCore` special case

Because every other kit depends on `KitoCore`, a **major** `KitoCore` release
forces at least a minor bump in every dependent kit (they must widen their
`from:` constraint) and a coordinated release. Treat `KitoCore` majors as
ecosystem events — plan them.

## Track B — KitoDevKit (curated set)

`KitoDevKit` versions differently. Its version is not a promise about its own
API surface (it has none — it's re-exports only). It is a promise about which
kit versions were **tested together**.

- **MAJOR** — one or more pinned kits went through a MAJOR bump, or a kit was
  added or removed from the curated set.
- **MINOR** — one or more pinned kits went through a MINOR bump.
- **PATCH** — one or more pinned kits went through a PATCH bump.

The pins in [Package.swift](../Package.swift) use `.exact(...)`. This is
deliberate. `from:` would let SPM float children between KitoDevKit releases and
break the "tested together" guarantee.

### Example matrix

| KitoDevKit | KitoCore | KitoButtons | KitoFields | KitoScreens |
| --- | --- | --- | --- | --- |
| 1.0.0 | 1.0.0 | 1.0.0 | 1.0.0 | 1.0.0 |
| 1.1.0 | 1.0.0 | 1.1.0 | 1.0.0 | 1.1.0 |
| 1.1.1 | 1.0.0 | 1.1.1 | 1.0.0 | 1.1.0 |
| 2.0.0 | 2.0.0 | 2.0.0 | 2.0.0 | 2.0.0 |

## Choosing which to depend on

- **App consumer:** `KitoDevKit`. Take a curated set, don't think about it.
- **Library consumer:** individual kits, with narrow SemVer ranges. A library
  that depends on `KitoDevKit` transitively forces its downstream consumers to
  also curate through KitoDevKit, which is rude.

## Release safety split (planned)

`KitoDevKit` re-exports only release-safe kits. When Kito grows QA/dev tooling,
those kits will roll up into a separate `KitoDevKitDebug` umbrella. A consumer
who wants both writes:

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoDevKit.git", from: "2.0.0"),
.package(url: "https://github.com/WykSofts-Inc/KitoDevKitDebug.git", from: "2.0.0"),
```

…and conditionally imports the debug umbrella with `#if DEBUG`. Never mix the
two into one umbrella — that erases the guarantee.

## What triggers a KitoDevKit release

1. Any pinned kit ships a new tag we consider stable.
2. We update `Package.swift` here to that tag.
3. Run the umbrella tests and the Sample app.
4. Cut a KitoDevKit tag whose semantics follow the table above.

See [RELEASING.md](RELEASING.md) for the mechanical steps.
