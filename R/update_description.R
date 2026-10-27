#' @title Change the `Remotes` field in DESCRIPTION
#'
#' @description
#' Update the `Remotes` field of a package DESCRIPTION file so that
#' dependencies point to specific development targets
#' (`develop`, `snapshot`, or `main`).
#'
#' @inheritParams set_latest_rjdverse_version
#' @param target [\link[base]{character}] Remote reference to write after the
#'   `@` separator: `"develop"` (branch `develop`), `"snapshot"`
#'   (branch `snapshot`) or `"main"` (release tracking, written as
#'   `*release` in the `Remotes` field).
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
    path <- normalizePath(path, mustWork = TRUE)
    target <- match.arg(arg = target)
    remotes <- desc::desc_get_remotes(path)
    if (length(remotes) == 0L) {
        if (verbose) {
            message("No Remotes field found in DESCRIPTION; nothing to change.")
        }
        return(invisible(NULL))
    }

    basic_remotes <- remotes |>
        strsplit(split = "@", fixed = TRUE) |>
        vapply(FUN = `[`, 1L, FUN.VALUE = character(1L))

    new_remotes <- paste0(
        basic_remotes,
        "@",
        switch(
            target,
            develop = "develop",
            main = "*release",
            snapshot = "snapshot"
        )
    )

    if (identical(sort(remotes), sort(new_remotes))) {
        if (verbose) {
            message(
                "The remote field is already up to date",
                " and will not be changed."
            )
        }
        return(invisible(remotes))
    }
    if (verbose) {
        message("Current remotes fields:")
        message(remotes)
        message("New remotes fields:")
        message(new_remotes)
    }
    desc::desc_set_remotes(remotes = new_remotes, file = path)
    attachment::att_amend_desc(
        path = path,
        normalize = TRUE,
        must.exist = FALSE,
        update.config = FALSE,
        use.config = FALSE,
        document = FALSE
    )
    desc::desc_normalize(file = path)
    return(invisible(new_remotes))
}

#' @title Set latest versions for GitHub dependencies
#'
#' @description
#' Update the `DESCRIPTION` file of a package so that all dependencies
#' whose name starts with `rjd3` require the latest released version
#' from the rjdverse.
#'
#' @param path [\link[base]{character}] Path to the package root directory (or
#'   to the DESCRIPTION / NEWS.md file).
#' @param verbose [\link[base]{logical}] Whether to print additional
#'   information (default: `TRUE`).
#'
#' @returns Used for its side effect on the `DESCRIPTION` file
#' (no return value).
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
#' set_latest_rjdverse_version(path = path_rjd3workspace)
#' }
#'
#' @export
#' @importFrom desc desc_get_deps desc_set_dep
set_latest_rjdverse_version <- function(
    path,
    verbose = TRUE
) {
    path <- normalizePath(path, mustWork = TRUE)
    cur_deps <- desc::desc_get_deps(path)
    row_deps <- which(startsWith(prefix = "rjd3", x = cur_deps$package))
    for (idx in row_deps) {
        pkg <- cur_deps$package[idx]
        pkg_type <- cur_deps$type[idx]
        latest_version <- get_latest_version(
            gh_repo = file.path("rjdverse", pkg)
        )
        desc::desc_set_dep(
            package = pkg,
            version = paste(">=", latest_version),
            type = pkg_type,
            file = path
        )
    }
    attachment::att_amend_desc(
        path = path,
        normalize = TRUE,
        must.exist = FALSE,
        update.config = FALSE,
        use.config = FALSE,
        document = FALSE
    )
    desc::desc_normalize(file = path)
}

#' @title Set organization remotes in the Remotes field
#'
#' @description
#' Add GitHub remotes to the `Remotes` field of the `DESCRIPTION` file
#' for the dependencies of a given GitHub organization.
#'
#' @details
#' All dependencies whose package name starts with `rjd3`
#' (rjdverse packages by default) are added to the `Remotes` field as
#' GitHub remotes of `rjdverse`.
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
set_rjdverse_remotes <- function(
    path,
    verbose = TRUE
) {
    path <- normalizePath(path)
    remotes <- desc::desc_get_remotes(path)
    cur_deps <- desc::desc_get_deps(path)
    cond_deps <- startsWith(prefix = "rjd3", x = cur_deps$package)
    deps <- cur_deps$package[cond_deps]
    new_remotes <- file.path("github::rjdverse", deps)

    if (identical(sort(remotes), sort(new_remotes))) {
        if (verbose) {
            message(
                "The remote field is already up to date",
                " and will not be changed."
            )
        }
        return(invisible(remotes))
    }

    desc::desc_set_remotes(remotes = new_remotes, file = path)
    if (verbose) {
        message("Enabled remotes: ", toString(new_remotes))
    }
    attachment::att_amend_desc(
        path = path,
        normalize = TRUE,
        must.exist = FALSE,
        update.config = FALSE,
        use.config = FALSE,
        document = FALSE
    )
    desc::desc_normalize(file = path)
    invisible(new_remotes)
}
