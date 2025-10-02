#' @title Change the `Remotes` field in DESCRIPTION
#'
#' @description
#' Update the `Remotes` field of a package DESCRIPTION file so that
#' dependencies point to specific development targets
#' (`develop`, `snapshot`, or `main`).
#'
#' @param path [\link[base]{character}] Path to the package root directory
#' containing a `DESCRIPTION` file (default: `"."`).
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
change_remotes_field <- function(path = ".", verbose = TRUE, target = c("develop", "snapshot", "main")) {
    remotes <- desc::desc_get_remotes(path)
    if (length(remotes) == 0L) return(NULL)

    basic_remotes <- remotes |>
        strsplit(split = "@") |>
        vapply(FUN = `[`, 1L, FUN.VALUE = character(1L))

    new_remotes <-  paste0(
        basic_remotes, "@",
        switch(
            EXPR = target,
            develop = "develop",
            main ="*release",
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
#' @param path [\link[base]{character}] Path to the package root directory
#' (default: `"."`).
#' @param verbose [\link[base]{logical}] Whether to print progress messages
#' (default: `TRUE`).
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
        latest_version <- get_latest_version(gh_repo = paste0("rjdverse/", pkg))
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
#' @param new_version [\link[base]{character}] The new version number (e.g. `"1.2.3"`).
#' @param path [\link[base]{character}] Path to the package root directory
#' containing `NEWS.md`.
#' @param github_url [\link[base]{character}] Base URL of the package GitHub
#' repository (e.g. `"https://github.com/owner/repo"`).
#'
#' @return Invisibly returns `TRUE` if the file was successfully updated.
#'
#' @examples
#' \dontrun{
#' update_news_md(new_version = "1.2.3",
#'                path = ".",
#'                github_url = "https://github.com/rjdverse/rjd3toolkit")
#' }
#'
#' @export
update_news_md <- function(new_version, path, github_url) {
    changelog <- readLines(con = file.path(path, "NEWS.md"))

    line_number <- which(changelog == "## [Unreleased]")
    new_line <- paste0("## [", new_version, "] - ", Sys.Date())
    changelog <- c(changelog[seq_len(line_number)], "", new_line, "", changelog[-seq_len(line_number)])

    line_footer <- grepl(
        pattern = paste0("^\\[Unreleased\\]: ", github_url, "\\/compare\\/.*\\.\\.\\.HEAD$"),
        x = changelog
    ) |>
        which()

    # Get line comparison Unreleased
    old_compare_head <- changelog[line_footer]
    pattern <- "v[0-9]+\\.[0-9]+\\.[0-9]+"

    # New line comparison HEAD
    new_compare_head <- gsub(pattern = pattern, replacement = paste0("v", new_version), x = old_compare_head)

    # New comparison old version
    new_compare_old_version <- old_compare_head |>
        gsub(pattern = "Unreleased", replacement = new_version) |>
        gsub(pattern = "HEAD", replacement = paste0("v", new_version))

    changelog <- c(
        changelog[seq_len(line_footer - 1L)],
        new_compare_head,
        new_compare_old_version,
        changelog[-seq_len(line_footer)]
    )

    writeLines(text = changelog, con = file.path(path, "NEWS.md"))
    return(invisible(TRUE))
}
