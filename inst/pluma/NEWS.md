# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

## [0.3.0] - 2025-10-29

### Added
- New `render_docx()` function for precise Word rendering with custom templates.
- Added syntax highlighting themes ("ink", "sand", "noir").
- Introduced `pluma::draft()` to scaffold starter documents interactively.

### Changed
- Improved error reporting with colored CLI messages.
- Updated PDF rendering backend for better font embedding.

### Fixed
- Fixed incorrect path handling on Windows.
- Resolved issue with inline code blocks breaking in HTML output.


## [0.2.0] - 2025-07-12

### Added
- Support for PDF output using `tinytex`.
- New YAML options: `title`, `author`, `theme`, `output_format`.
- Added unit tests for rendering pipeline.

### Changed
- Default output format is now HTML.
- Refactored `pluma_render()` for cleaner output logging.

### Deprecated
- Deprecated `pluma_convert()` in favor of `pluma_render()`.


## [0.1.0] - 2025-03-04

### Added
- Initial release of  {pluma}.
- Basic HTML rendering from code blocks.
- Support for embedded R and Python snippets.
- Minimal CLI tool: `pluma render input.Rmd -o output.html`.


[Unreleased]: https://github.com/fictive-lab/pluma/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/fictive-lab/pluma/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/fictive-lab/pluma/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/fictive-lab/pluma/releases/tag/v0.1.0
