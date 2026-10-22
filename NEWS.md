# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Tests for the documentation checking functions (`check_docs()` and the `check_*()` family).
* `get_latest_version()` gains a `max_branches` argument (default: `50L`) to limit the number of GitHub API calls on repositories with many branches.
* New function `amend_description()`, a wrapper around `attachment::att_amend_desc()` that aligns the `DESCRIPTION` dependencies with the packages used in the code. `attachment` is a Suggested package. Call it **before** `change_remotes_field()` / `set_latest_rjdverse_version()`, since `att_amend_desc()` drops the remotes of packages it does not find in the code.

### Changed

* `get_version_from_branch()` now checks that the branch exists in the repository before fetching its `DESCRIPTION`, raising a clear error otherwise. Use `check_branch = FALSE` to skip the check.
* User-facing messages are now written in English for consistency.
* The default `gh_repo` argument is now `r-lib/usethis` instead of `rjdverse/rjd3toolkit`.
* `check_docs()` uses `verbose = TRUE` by default, consistently with the other functions.
* User-facing diagnostic messages consistently use `message()`.
* `get_different_future_version()` no longer forwards the `desc` version bump messages; only its own `verbose` messages are printed.
* `check_missing_examples_content()` now detects a function in its examples only when it is actually called (e.g. `my_fun(...)`), instead of matching the bare name as a substring.
* `change_remotes_field()` and `set_latest_rjdverse_version()` now normalize the field order of the `DESCRIPTION` file after modifying it (`desc::desc_normalize()`).

### Fixed

* `get_latest_version()` no longer fails when the repository has no release: it falls back to the version of the default branch.
* `get_latest_version()` no longer emits a deprecation warning: it relies on an internal helper instead of the deprecated `get_github_branches()`.
* `get_latest_version()` reports branches whose `DESCRIPTION` cannot be read instead of silently swallowing the error.
* `change_remotes_field()` now validates `target` with `match.arg()`, preventing a corrupted `Remotes` field when an invalid value is passed.
* `change_remotes_field()` informs the user (when `verbose = TRUE`) that there is nothing to do when the package has no `Remotes` field, instead of returning silently.
* The print method of `releaser_doc_check` now displays a proper check mark (`\u2713`) for passing checks instead of a stray space.

## [1.2.1] - 2026-07-31

### Changed

* The argument `enabled` is removed from `set_rjdverse_remotes`. Now the function only enable the Remotes field.

### Deprecated

* `update_news_md` is deprecated. Please use the project [heylogs](https://github.com/nbbrd/heylogs) from the [nbbrd](https://github.com/nbbrd/) instead.
* `get_changes` is deprecated. Please use the project [heylogs](https://github.com/nbbrd/heylogs) from the [nbbrd](https://github.com/nbbrd/) instead.

## [1.2.0] - 2026-07-02

### Added

* New function `set_rjdverse_remotes()` to clear the Remotes field from rjdverse packages or to add the rjdverse dependencies to the Remotes field.

### Fixed

* Remove examples tested if PAT not provided.

## [1.1.0] - 2026-03-11

### Added

* New functions to check the documentation of a package R.

### Fixed

* url of GitHub repo with desc pkg.

## [1.0.0] - 2025-10-29

### Changed

* order of the argument
* Add {rjd3workspace} DESCRIPTION and NEWS.md as example

### Removed

* argument `gh_repo` from `update_news_md()`

### Added

* Add files and function to extract information from description (based on {desc}).
* Add function to extract version from GitHub or from an R package.
* New functions to modify the DESCRIPTION and NEWS.md files for release
* Implemented progress and diagnostic messages when `verbose = TRUE` to aid debugging and transparency.

[Unreleased]: https://github.com/TanguyBarthelemy/releaser/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/TanguyBarthelemy/releaser/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/TanguyBarthelemy/releaser/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/TanguyBarthelemy/releaser/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/TanguyBarthelemy/releaser/releases/tag/v1.0.0
