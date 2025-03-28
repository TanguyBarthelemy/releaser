#' @export
change_remotes_field <- function(path = ".", verbose = TRUE, target = c("develop", "snapshot", "main")) {
    remotes <- desc::desc_get_remotes(path)
    if (length(remotes) == 0) return(NULL)

    basic_remotes <- remotes |> strsplit("@") |> sapply(`[`, 1L)

    new_remotes <- switch(
        EXPR = target,
        develop = basic_remotes,
        main = paste0(basic_remotes, "@*release"),
        snapshot = paste0(basic_remotes, "@snapshot")
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

    # Utiliser regmatches et gregexpr pour extraire le numéro de version
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
