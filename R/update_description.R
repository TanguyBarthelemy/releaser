#' @title Change the `Remotes` field in DESCRIPTION
#'
#' @description
#' Update the `Remotes` field of a package DESCRIPTION file so that
#' dependencies point to specific development targets
#' (`develop`, `snapshot`, or `main`).
#'
#' @param path [\link[base]{character}] Path to the package root directory
#' (default: `"."`).
#' @param verbose [\link[base]{logical}] Whether to print current and new
#' remote fields (default: `TRUE`).
#' @param target [\link[base]{character}] Target branch or type of remote:
#' must be one of `"develop"`, `"snapshot"`, or `"main"`.
#'
#' @return Invisibly returns the new vector of remote specifications
#' (character).
#'
#' @examples
#' \dontrun{
#' change_remotes_field(path = ".", target = "develop")
#' }
#'
#' @export
#' @importFrom desc desc_get_remotes desc_set_remotes
change_remotes_field <- function(
    path = ".",
    verbose = TRUE,
    target = c("develop", "snapshot", "main")
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
#' @inheritParams change_remotes_field
#'
#' @return Invisibly updates the `DESCRIPTION` file in place.
#'
#' @examples
#' \dontrun{
#' set_latest_deps_version(path = ".")
#' }
#'
#' @export
#' @importFrom desc desc_get_deps desc_set_dep
set_latest_deps_version <- function(path = ".", verbose = TRUE) {
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
#' @param new_version [\link[base]{character}] The new version number (e.g.
#' `"1.2.3"`).
#' @inheritParams change_remotes_field
#'
#' @return Invisibly returns `TRUE` if the file was successfully updated.
#'
#' @examples
#' \dontrun{
#' update_news_md(new_version = "1.2.3",
#'                path = ".",
#'                gh_repo = "rjdverse/rjd3toolkit")
#' }
#'
#' @export
update_news_md <- function(new_version, path = ".", verbose = TRUE) {
    if (verbose) {
        message("Updating NEWS.md for version: ", new_version)
    }
    changelog <- readLines(con = file.path(path, "NEWS.md"))
    urls <- regmatches(
        changelog ,
        regexpr("https://github\\.com/[^/]+/[^/]+", changelog )
    )
    github_url <- unique(urls)

    line_number <- which(changelog == "## [Unreleased]")
    new_line <- paste0("## [", new_version, "] - ", Sys.Date())
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
        replacement = paste0("v", new_version),
        x = old_compare_head
    )
    new_compare_old_version <- old_compare_head |>
        gsub(pattern = "Unreleased", replacement = new_version, fixed = TRUE) |>
        gsub(
            pattern = "HEAD",
            replacement = paste0("v", new_version),
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
