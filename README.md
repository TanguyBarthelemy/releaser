
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {releaser}

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/releaser)](https://CRAN.R-project.org/package=releaser)

[![R-CMD-check](https://github.com/TanguyBarthelemy/releaser/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/TanguyBarthelemy/releaser/actions/workflows/R-CMD-check.yaml)
[![Test
coverage](https://codecov.io/gh/TanguyBarthelemy/releaser/branch/main/graph/badge.svg)](https://app.codecov.io/gh/TanguyBarthelemy/releaser?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/tanguybarthelemy/releaser/badge/main)](https://www.codefactor.io/repository/github/tanguybarthelemy/releaser/overview/main)
[![Codacy
Badge](https://app.codacy.com/project/badge/Grade/d5265973b095439e815a1bd64e5bbb00)](https://app.codacy.com/gh/TanguyBarthelemy/releaser/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![lint](https://github.com/TanguyBarthelemy/releaser/actions/workflows/lint.yaml/badge.svg)](https://github.com/TanguyBarthelemy/releaser/actions/workflows/lint.yaml)

[![GH Pages
built](https://github.com/TanguyBarthelemy/releaser/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/TanguyBarthelemy/releaser/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

{releaser} helps the developer to release their package and update
informations (DESCRIPTION, CHANGELOG…) of the package.

## Installation

You can install the development version of {releaser} from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("TanguyBarthelemy/releaser")
```

## Usage

``` r
library("releaser")
```

You can extract the latest version of a package on GitHub and display
the different future version:

``` r
version <- get_latest_version("rjdverse/rjd3toolkit")
#> Fetched DESCRIPTION from branch: v3.5.1
#> Version found on branch v3.5.1: 3.5.1
#> Dernière release : 3.5.1
#> Fetching branches from repository: rjdverse/rjd3toolkit
#> Found branches: develop, gh-pages, main, snapshot
#> Fetched DESCRIPTION from branch: develop
#> Version found on branch develop: 3.5.2
#> Version sur develop  : 3.5.2
#> Fetched DESCRIPTION from branch: main
#> Version found on branch main: 3.5.1
#> Version sur main  : 3.5.1
#> Fetched DESCRIPTION from branch: snapshot
#> Version found on branch snapshot: 3.5.1.9500
#> Version sur snapshot  : 3.5.1.9500
get_different_future_version(version)
#> Package version bumped from '3.5.1' to '3.5.2'
#> Future patch version: 3.5.2
#> Package version bumped from '3.5.2' to '3.6.0'
#> Future minor version: 3.6.0
#> Package version bumped from '3.6.0' to '4.0.0'
#> Future major version: 4.0.0
#> current_version.Version    future_patch_version    future_minor_version 
#>                 "3.5.1"                 "3.5.2"                 "3.6.0" 
#>    future_major_version 
#>                 "4.0.0"
```
