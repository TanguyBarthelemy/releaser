
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {releaser}

<!-- badges: start -->

[![R-CMD-check](https://github.com/TanguyBarthelemy/releaser/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/TanguyBarthelemy/releaser/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/TanguyBarthelemy/releaser/graph/badge.svg)](https://app.codecov.io/gh/TanguyBarthelemy/releaser)
<!-- badges: end -->

{relaser} helps the developer to release their package and update
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
#> Dernière release : 3.5.1 
#> Version sur main : 3.5.1 
#> Version sur develop : 3.5.1.9000
get_different_future_version(version)
#> Package version bumped from '3.5.1' to '3.5.2'
#> Package version bumped from '3.5.2' to '3.6.0'
#> Package version bumped from '3.6.0' to '4.0.0'
#> current_version.Version    future_patch_version    future_minor_version 
#>                 "3.5.1"                 "3.5.2"                 "3.6.0" 
#>    future_major_version 
#>                 "4.0.0"
```
