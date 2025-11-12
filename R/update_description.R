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
#' @return Invisibly returns the new vector of remote specifications
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
#' @importFrom desc desc_get_remotes desc_set_remotes
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
#' @param path [\link[base]{character}] Path to the package root directory.
#' @param verbose [\link[base]{logical}] Whether to print current and new
#' remote fields (default: `TRUE`).
#'
#' @return Invisibly updates the `DESCRIPTION` file in place.
#'
#' @examples
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

#' @title Update `NEWS.md` for a new release
#'
#' @description
#' Modify the `NEWS.md` file of a package to replace the `"Unreleased"`
#' section with a new version heading and update GitHub comparison links.
#'
#' @inheritParams get_changes
#'
#' @return Invisibly returns `TRUE` if the file was successfully updated.
#'
#' @details
#' The argument `version_number` is the new version number to update the
#' changelog.
#'
#' @examples
#' path_rjd3workspace <- file.path(tempdir(), "rjd3workspace")
#' file.copy(
#'     from = system.file("rjd3workspace", package = "releaser"),
#'     to = dirname(path_rjd3workspace),
#'     recursive = TRUE
#' )
#'
#' update_news_md(path = path_rjd3workspace, version_number = "1.2.3")
#'
#' @export
update_news_md <- function(path, version_number, verbose = TRUE) {
    if (verbose) {
        message("Updating NEWS.md for version: ", version_number)
    }
    changelog <- readLines(con = file.path(path, "NEWS.md"))
    urls <- regmatches(
        x = changelog,
        regexpr(pattern = "https://github\\.com/[^/]+/[^/]+", text = changelog)
    )
    github_url <- unique(urls)

    line_number <- which(changelog == "## [Unreleased]")
    new_line <- paste0("## [", version_number, "] - ", Sys.Date())
    changelog <- c(
        changelog[seq_len(line_number)],
        "",
        new_line,
        "",
        changelog[-seq_len(line_number)]
    )
    if (verbose) {
        message("Inserted new version header after 'Unreleased' section.")
    }

    line_footer <- grepl(
        pattern = paste0(
            "^\\[Unreleased\\]: ",
            github_url,
            "\\/compare\\/.*\\.\\.\\.HEAD$"
        ),
        x = changelog
    ) |>
        which()

    old_compare_head <- changelog[line_footer]
    pattern <- "v[0-9]+\\.[0-9]+\\.[0-9]+"

    new_compare_head <- gsub(
        pattern = pattern,
        replacement = paste0("v", version_number),
        x = old_compare_head
    )
    new_compare_old_version <- old_compare_head |>
        gsub(
            pattern = "Unreleased",
            replacement = version_number,
            fixed = TRUE
        ) |>
        gsub(
            pattern = "HEAD",
            replacement = paste0("v", version_number),
            fixed = TRUE
        )

    changelog <- c(
        changelog[seq_len(line_footer - 1L)],
        new_compare_head,
        new_compare_old_version,
        changelog[-seq_len(line_footer)]
    )

    writeLines(text = changelog, con = file.path(path, "NEWS.md"))
    if (verbose) {
        message("NEWS.md successfully updated and written to disk.")
    }
    return(invisible(TRUE))
}
