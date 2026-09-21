# Publishing

Swift Package Manager reads packages from Git. There is no upload step, no
CocoaPods trunk, no Maven Central. Publishing a Kito kit is:

1. Commit and push to the kit's GitHub repo.
2. Tag a SemVer version.
3. Push the tag.

That is it. The moment the tag exists on GitHub, `.package(url:from:)` can
resolve it.

## Repo hygiene each kit needs

- A `Package.swift` at the repo root using `swift-tools-version: 5.9` or newer.
- One or more `library` products.
- A `README.md` with an install snippet.
- A `LICENSE` file.
- SemVer tags starting from `1.0.0` (SPM ignores tags without a `Package.swift`
  in that commit, so make sure the tagged commit is buildable).
- A `Tests/` directory — even minimal tests keep the resolver honest.

## GitHub Releases vs Git tags

SPM resolves against **tags**. GitHub Releases are for humans (changelog notes,
attached assets). Every KitoDevKit release should have a GitHub Release with:

- The child matrix pasted in.
- Links to each child kit's release notes.
- A short summary of what changed and why a consumer would update.

## Optional: index the ecosystem

Once each kit is public and tagged, submit them to the
[Swift Package Index](https://swiftpackageindex.com/add-a-package). That gives
each kit search visibility, generated docs, platform compatibility badges, and
a one-liner install snippet in the sidebar — a real amplifier for adoption.

## Optional: doc hosting

For a docs site like `ezekielwachira.github.io/DevKit`, use DocC:

```bash
xcrun docc convert Sources/KitoCore/KitoCore.docc \
  --output-path ./docs \
  --hosting-base-path KitoCore
```

Push `./docs` to a `gh-pages` branch on each kit and enable GitHub Pages. The
umbrella site can be a hand-written landing page that links each kit's DocC
output.

## Signing (nothing to do)

SPM does not require artifact signing. Repos, tags, and the resolver do the
work. Keep your GitHub account's 2FA on.
