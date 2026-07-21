# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/TanguyBarthelemy/releaser/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/TanguyBarthelemy/releaser/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/TanguyBarthelemy/releaser/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/TanguyBarthelemy/releaser/releases/tag/v1.0.0
