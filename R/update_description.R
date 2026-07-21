#' @title Change the `Remotes` field in DESCRIPTION
#'
#' @description
#' Update the `Remotes` field of a package DESCRIPTION file so that
#' dependencies point to specific development targets
#' (`develop`, `snapshot`, or `main`).
#'
#' @inheritParams set_latest_deps_version
#' @param target [\link[base]{character}] Target branch or type of remote:
#' must be one of `"develop"`, `"snapshot"`, or `"main"`.
#'
#' @returns Invisibly returns the new vector of remote specifications
#' (character).
#'
#' @examples
#' path_rjd3workspace <- file.path(tempdir(), "rjd3workspace")
#' file.copy(
#'     from = system.file("rjd3workspace", package = "releaser"),
#'     to = dirname(path_rjd3workspace),
#'     recursive = TRUE
#' )
#'
#' change_remotes_field(path = path_rjd3workspace, target = "develop")
#'
#' @export
#' @importFrom desc desc_set_remotes
#' @importFrom desc desc_get_remotes
change_remotes_field <- function(
    path,
    target = c("develop", "snapshot", "main"),
    verbose = TRUE
) {
    remotes <- desc::desc_get_remotes(path)
    if (length(remotes) == 0L) {
        return(NULL)
    }

    basic_remotes <- remotes |>
        strsplit(split = "@", fixed = TRUE) |>
        vapply(FUN = `[`, 1L, FUN.VALUE = character(1L))

    new_remotes <- paste0(
        basic_remotes,
        "@",
        switch(
            EXPR = target,
            develop = "develop",
            main = "*release",
            snapshot = "snapshot"
        )
    )

    if (identical(sort(remotes), sort(new_remotes))) {
        if (verbose) {
            message("The remote field is already up to date",
                    " and will not be changed.")
        }
        return(invisible(remotes))
    }
    if (verbose) {
        cat("Current remotes fields :\n")
        cat(remotes, "\n")
        cat("New remotes fields :\n")
        cat(new_remotes, "\n")
        cat("\n")
    }
    desc::desc_set_remotes(remotes = new_remotes, file = path)
    return(invisible(new_remotes))
}

#' @title Set latest versions for `rjd3*` dependencies
#'
#' @description
#' Update the `DESCRIPTION` file of a package so that all dependencies
#' beginning with `"rjd3"` require the latest released version from GitHub.
#'
#' @param path [\link[base]{character}] Path to the package root directory (or
#'   to the DESCRIPTION / NEWS.md file).
#' @param verbose [\link[base]{logical}] Whether to print additional
#'   information (default: `TRUE`).
#'
#' @returns Invisibly updates the `DESCRIPTION` file in place.
#'
#' @examplesIf FALSE
#' \donttest{
#' path_rjd3workspace <- file.path(tempdir(), "rjd3workspace")
#' file.copy(
#'     from = system.file("rjd3workspace", package = "releaser"),
#'     to = dirname(path_rjd3workspace),
#'     recursive = TRUE
#' )
#'
#' set_latest_deps_version(path = path_rjd3workspace)
#' }
#'
#' @export
#' @importFrom desc desc_get_deps desc_set_dep
set_latest_deps_version <- function(path, verbose = TRUE) {
    cur_deps <- desc::desc_get_deps(path)
    row_rjdverse <- grep(cur_deps$package, pattern = "^rjd3")
    for (idx in row_rjdverse) {
        pkg <- cur_deps$package[idx]
        pkg_type <- cur_deps$type[idx]
        latest_version <- get_latest_version(
            gh_repo = file.path("rjdverse", pkg)
        )
        desc::desc_set_dep(
            package = pkg,
            version = paste(">=", latest_version),
            type = pkg_type,
            file = file.path(path, "DESCRIPTION"),
            normalize = TRUE
        )
    }
}

#' @title Set the rjdverse in the Remotes field
#'
#' @description
#' Add or remove rjdverse packages from the Remotes field of the
#' DESCRIPTION file.
#'
#' @details
#' All dependencies whose package name starts with "rjd3" (rjdverse packages)
#' are added to the Remotes field as GitHub remotes.
#'
#' @param path Path to the root of the package.
#' @param verbose Logical. Should informative messages be displayed?
#'
#' @returns Invisibly the current content of the `Remotes` field.
#' @export
#'
#' @examples
#' path_rjd3workspace <- file.path(tempdir(), "rjd3workspace")
#' file.copy(
#'     from = system.file("rjd3workspace", package = "releaser"),
#'     to = dirname(path_rjd3workspace),
#'     recursive = TRUE
#' )
#'
#' set_rjdverse_remotes(path = path_rjd3workspace)
#'
set_rjdverse_remotes <- function(path, verbose = TRUE) {
    remotes <- desc::desc_get_remotes(path)
    cur_deps <- desc::desc_get_deps(path)
    cond_rjdverse <- startsWith(prefix = "rjd3", x = cur_deps$package)
    rjdverse <- cur_deps$package[cond_rjdverse]
    new_remotes <- file.path("github::rjdverse", rjdverse)

    if (identical(sort(remotes), sort(new_remotes))) {
        if (verbose) {
            message("The remote field is already up to date",
                    " and will not be changed.")
        }
        return(invisible(remotes))
    }

    desc::desc_set_remotes(remotes = new_remotes, file = path)
    if (verbose) {
        message("Enabled rjdverse remotes: ", toString(new_remotes))
    }
    invisible(new_remotes)
}
