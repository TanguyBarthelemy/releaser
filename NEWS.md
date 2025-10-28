# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Removed

* argument `gh_repo` from `update_news_md()`


### Added

* Add files and function to extract information from description (based on {desc}).
* Add function to extract version from GitHub or from an R package.
* New functions to modify the DESCRIPTION and NEWS.md files for release
* Implemented progress and diagnostic messages when `verbose = TRUE` to aid debugging and transparency.

[Unreleased]: https://github.com/TanguyBarthelemy/releaser/compare/main...HEAD
