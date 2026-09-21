# Releasing

Two flows: releasing a kit, and rolling that kit into a new KitoDevKit set.

## Releasing an individual kit

Applies to `KitoCore`, `KitoButtons`, `KitoFields`, `KitoScreens`.

1. Green tests on `main`.
2. Bump `Kito.version` in `KitoCore` if this is a `KitoCore` release; every
   other kit reads it, no change needed elsewhere.
3. Update the kit's `CHANGELOG.md` with the new tag and a short set of bullets
   under **Added / Changed / Fixed / Removed**.
4. Tag: `git tag -a 1.2.0 -m "1.2.0"` then `git push --tags`.
5. Create a GitHub Release from the tag with the changelog bullets pasted in.

That's the entire kit release flow. SPM consumers pick it up as soon as SPM
resolves against GitHub.

## Rolling a new KitoDevKit set

1. In `Package.swift` here, update `.exact(...)` pins for every kit you want in
   the new set. Do NOT loosen to `from:` — see VERSIONING.md.
2. `swift package resolve` locally, then `swift test` — the umbrella tests
   compile-check every re-export.
3. Open `Sample/` in Xcode, run on a simulator, tap through the sign-in and
   card-checkout screens. This is the "consumer-test" step.
4. Update `CHANGELOG.md` with what changed in each child (link back to each
   kit's own release notes).
5. Bump this repo's tag per [VERSIONING.md](VERSIONING.md) Track B.
6. Tag and push. Create a GitHub Release whose notes state the exact child
   matrix — this is the single source of truth for "what came with KitoDevKit 1.2.0".

## Pre-release checklist

Before any release (kit or umbrella):

- [ ] Public API diff reviewed. Anything renamed, removed, or with a changed
      signature? That is a MAJOR bump, no exceptions.
- [ ] Tests green including any snapshot tests.
- [ ] `swift package diagnose-api-breaking-changes` if the kit tracks it.
- [ ] `README.md` install snippet points at the new version number.
- [ ] `CHANGELOG.md` updated.

## After the release

- Tell the sample repo (`KitoDevKit/Sample`) — it's the smoke test for the
  next umbrella version, so it should already track the newest.
- If this was a `KitoCore` MAJOR release, open PRs on each dependent kit
  widening their SPM constraint to include the new major. Coordinate the
  landing so downstream consumers see one clean matrix bump.
