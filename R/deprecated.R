
#' @title Deprecated functions
#'
#' @description
#' `update_news_md` modify the `NEWS.md` file of a package to replace the
#' `"Unreleased"` section with a new version heading and update GitHub
#' comparison links.
#' `get_changes` extracts the section of `NEWS.md` corresponding to a given
#' version.
#'
#' @inheritParams change_remotes_field
#' @inheritParams get_different_future_version
#'
#' @returns `update_news_md` invisibly returns `TRUE` if the file was
#' successfully updated.
#' `get_changes` returns a character string containing the formatted changelog
#' for the given version.
#'
#' @details
#' The argument `version_number` is the new version number to update the
#' changelog.
#'
#' @importFrom desc desc_get_urls
#' @name releaser-deprecated
NULL

#' @export
#' @examplesIf FALSE
#' path_rjd3workspace <- file.path(tempdir(), "rjd3workspace")
#' file.copy(
#'     from = system.file("rjd3workspace", package = "releaser"),
#'     to = dirname(path_rjd3workspace),
#'     recursive = TRUE
#' )
#'
#' update_news_md(path = path_rjd3workspace, version_number = "1.2.3")
#' @rdname releaser-deprecated
update_news_md <- function(path, version_number, verbose = TRUE) {
    .Deprecated("Le projet heylogs : https://github.com/nbbrd/heylogs")
    if (verbose) {
        message("Updating NEWS.md for version: ", version_number)
    }
    changelog <- readLines(con = file.path(path, "NEWS.md"))
    urls <- regmatches(
        x = desc::desc_get_urls(file = path),
        m = regexpr(
            pattern = "https://github\\.com/[^/]+/[^/]+",
            text = desc::desc_get_urls(file = path)
        )
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

#' @export
#' @examplesIf FALSE
#' path_rjd3workspace <- system.file("rjd3workspace", package = "releaser")
#'
#' get_changes(path = path_rjd3workspace, version_number = "Unreleased")
#' get_changes(path = path_rjd3workspace, version_number = "3.2.4")
#' get_changes(path = path_rjd3workspace, version_number = "3.5.1")
#'
#' @rdname releaser-deprecated
get_changes <- function(path, version_number, verbose = TRUE) {
    .Deprecated("Le projet heylogs : https://github.com/nbbrd/heylogs")
    path <- normalizePath(path, mustWork = TRUE)
    changelog <- readLines(con = file.path(path, "NEWS.md"))
    if (verbose) {
        message("Reading NEWS.md from: ", path)
    }

    starting_line <- grep(
        pattern = paste0("^## \\[", version_number, "\\]"),
        x = changelog
    ) +
        1L

    if (length(starting_line) == 0L) {
        stop(
            "Version ",
            version_number,
            " doesn't exist for ",
            path,
            call. = FALSE
        )
    }

    ending_line <- c(
        grep(pattern = "^## \\[", x = changelog),
        grep("^\\[Unreleased\\]", changelog),
        length(changelog)
    )
    ending_line <- min(ending_line[ending_line > starting_line]) - 1L
    ref <- grep(pattern = paste0("^\\[", version_number, "\\]"), x = changelog)

    if (verbose) {
        message("Extracting changes for version: ", version_number)
    }

    changes <- changelog[starting_line:ending_line]
    result <- paste(c("## Changes", changes, changelog[ref]), collapse = "\n")

    if (verbose) {
        message(
            "Successfully extracted ",
            length(changes),
            " lines of changes."
        )
    }
    return(result)
}
