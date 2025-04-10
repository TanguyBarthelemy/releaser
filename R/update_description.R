#' @export
#' @importFrom desc desc_get_remotes desc_set_remotes
change_remotes_field <- function(path = ".", verbose = TRUE, target = c("develop", "snapshot", "main")) {
    remotes <- desc::desc_get_remotes(path)
    if (length(remotes) == 0) return(NULL)

    basic_remotes <- remotes |> strsplit("@") |> sapply(`[`, 1L)

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

#' @export
update_news_md <- function(new_version, file, pkg) {
    changelog <- readLines(con = file.path(file, "NEWS.md"))

    line_number <- which(changelog == "## [Unreleased]")
    new_line <- paste0("## [", new_version, "] - ", Sys.Date())
    changelog <- c(changelog[seq_len(line_number)], "", new_line, "", changelog[-seq_len(line_number)])

    line_footer <- grepl(
        pattern = paste0("^\\[Unreleased\\]: https:\\/\\/github\\.com\\/rjdverse\\/", pkg, "\\/compare\\/.*\\.\\.\\.HEAD$"),
        x = changelog
    ) |>
        which()

    old_compare_HEAD <- changelog[line_footer]
    pattern <- "v[0-9]+\\.[0-9]+\\.[0-9]+"

    # Get version number
    matches <- regmatches(old_compare_HEAD, gregexpr(pattern, old_compare_HEAD))[[1]]
    old_version <- matches[1]

    # New line comparison HEAD
    new_compare_HEAD <- gsub(pattern = pattern, replacement = paste0("v", new_version), x = old_compare_HEAD)

    # New comparison old version
    new_compare_old_version <- old_compare_HEAD |>
        gsub(pattern = "Unreleased", replacement = new_version) |>
        gsub(pattern = "HEAD", replacement = paste0("v", new_version))

    changelog <- c(
        changelog[seq_len(line_footer - 1)],
        new_compare_HEAD,
        new_compare_old_version,
        changelog[-seq_len(line_footer)]
    )

    writeLines(text = changelog, con = file.path(file, "NEWS.md"))
    return(invisible(TRUE))
}
