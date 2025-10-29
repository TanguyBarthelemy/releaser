# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Changed

* Rename `.jws_add()` into `jws_add()`


## [3.5.1] - 2025-06-19

### Added

* For compatibility reasons, some functions have been added again (`.jmp_name()`, `.jmp_sa()`, `.jmp_sa_count()`, `.jmp_sa_name()`, `.jsap_sa_count()`, `.jsap_sa_name()`)
* New functions have deprecated old functions (`get_metadata()`, `get_ts_metadata()`, `transfer_sa_item()`)

### Deprecated

* Function `.jmp_sa_count()` is deprecated. Please use function `sap_sai_count()` instead.
* Function `.jsap_sa_count()` is deprecated. Please use function `sap_sai_count()` instead.
* Function `.jmp_name()` is deprecated. Please use function `sap_name()` instead.
* Function `.jmp_sa()` is deprecated. Please use function `jsap_sai()` instead.
* Function `.jmp_sa_name()` is deprecated. Please use function `sap_sai_names()` instead.
* Function `.jsap_sa_name()` is deprecated. Please use function `sap_sai_names()` instead.
* Function `.jsai_ts_metadata()` is deprecated. Please use function `get_ts_metadata()` instead.
* Function `transfer_series()` is deprecated. Please use function `transfer_sa_item()` instead.
* Function `.jsai_metadata()` is deprecated. Please use function `get_metadata()` instead.

### Changed

* Simplified the modification of path in `update_path()`

### Removed

* `add_variable()` is removed. Please use now `add_variables()`


## [3.5.0] - 2025-04-10

### Added

* New functions to update the raw data path (`spreadsheet_update_path()` and `txt_update_path()`)

### Changed

* Rename the argument `jsa` in `jsai` in `read_sai()`, `.jsai_results()`, `.jsai_jresults()`, `.jsai_name()`, `.jsai_metadata()`, `.jsai_ts_metadata()`, `replace_sa_item()`, `get_raw_data()`, `get_ts()`, `get_comment()` and  `get_priority()`
* Rename the argument `ref_jsa` in `ref_jsai` in `set_ts_metadata()`

### Deprecated 

* Function `.jws_open()` is deprecated. Please use function `jws_open()` instead.
* Function `.jsap_name()` is deprecated. Please use function `sap_name()` instead.
* Function `.jsap_sai()` is deprecated. Please use function `jsap_sai()` instead.
* Function `.jsap_sai_count()` is deprecated. Please use function `sap_sai_count()` instead.
* Function `.jsap_sai_names()` is deprecated. Please use function `sap_sai_names` instead.
* Function `.jsai_name()` is deprecated. Please use function `sai_name()` instead.
* Function `.jws_sap()` is deprecated. Please use function `jws_sap()` instead.
* Function `.jws_sap_count()` is deprecated. Please use function `ws_sap_count()` instead.
* Function `.jws_sap_new()` is deprecated. Please use function `jws_sap_new()` instead.
* Function `.jmp_load()` is deprecated. Please use function `read_sap()` instead.
* Function `.jsa_read()` is deprecated. Please use function `read_sai()` instead.
* Function `.jsa_results()` is deprecated. Please use function `.jsai_results()` instead.
* Function `.jsa_jresults()` is deprecated. Please use function `.jsai_jresults()` instead.
* Function `.jsa_metadata()` is deprecated. Please use function `.jsai_metadata()` instead.
* Function `.jsa_ts_metadata()` is deprecated. Please use function `.jsai_ts_metadata()` instead.
* Function `.jread_workspace()` is deprecated. Please use function `jread_workspace()` instead.
* Function `.jread_sap()` is deprecated. Please use function `jread_sap()` instead.
* Function `.jws_new()` is deprecated. Please use function `jws_new()` instead.
* Function `.jws_make_copy()` is deprecated. Please use function `jws_make_copy()` instead.
* Function `.jsap_make_copy()` is deprecated. Please use function `jsap_make_copy()` instead.
* Function `.jws_compute()` is deprecated. Please use function `jws_compute()` instead.
* Function `.jsap_sai()` is deprecated. Please use function `jsap_sai()` instead.
* Function `.jsap_refresh` is deprecated. Please use function `jsap_refresh` instead.
* Function `.jws_refresh` is deprecated. Please use function `jws_refresh` instead.

### Removed

* `.jmp_name()` is removed. Please use now `sap_name()`
* `.jws_load()` is removed. Please use now `jws_open()`
* `.jmp_sa()` is removed. Please use now `jsap_sai()`
* `.jsap_sa()` is removed. Please use now `jsap_sai()`
* `.jmp_sa_count()` is removed. Please use now `sap_sai_count()`
* `.jsap_sa_count()` is removed. Please use now  `sap_sai_count()`
* `.jmp_sa_name()` is removed. Please use now `sap_sai_names()`
* `.jsap_sa_name()` is removed. Please use now `sap_sai_names()`
* `.jsa_name()` is removed. Please use now `sai_name()`
* `.jws_multiprocessing()` is removed. Please use now `jws_sap()`
* `.jws_multiprocessing_count()` is removed. Please use now `ws_sap_count()`
* `.jws_multiprocessing_new()` is removed. Please use now `jws_sap_new()`


## [3.2.4] - 2025-02-04

### Fixed

* fixed `set_specification()` and `set_domain_specification()`
* Correction of imports when the workspace contains no SAP.
* `replace` parameter of `save_workspace()` corrected in R (not in Java).

### Added

* new function `.jsa_jresults()`, `.jread_sap()` and `.jread_workspace()` to  extract the Java object of the results of a SAItem.


## [3.2.3] - 2024-07-12

### Changed

* new jars


## [3.2.2] - 2024-03-15


## [3.2.1] - 2023-12-12


## [3.2.0] - 2023-11-24


## [3.1.0] - 2023-08-11


[Unreleased]: https://github.com/rjdverse/rjd3workspace/compare/v3.5.1...HEAD
[3.5.1]: https://github.com/rjdverse/rjd3workspace/compare/v3.5.0...v3.5.1
[3.5.0]: https://github.com/rjdverse/rjd3workspace/compare/v3.2.4...v3.5.0
[3.2.4]: https://github.com/rjdverse/rjd3workspace/compare/v3.2.3...v3.2.4
[3.2.3]: https://github.com/rjdverse/rjd3workspace/compare/v3.2.2...v3.2.3
[3.2.2]: https://github.com/rjdverse/rjd3workspace/compare/v3.2.1...v3.2.2
[3.2.1]: https://github.com/rjdverse/rjd3workspace/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/rjdverse/rjd3workspace/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/rjdverse/rjd3workspace/releases/tag/v3.1.0
