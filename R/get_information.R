#' @title Compute possible future semantic versions
#'
#' @description
#' Given a current package version, compute the potential next
#' patch, minor, and major versions following semantic versioning rules.
#'
#' @param version_number [\link[base]{character}] Current version number string
#' (e.g. `"1.2.3"`).
#' @inheritParams change_remotes_field
#'
#' @return A named character vector with:
#' \itemize{
#'   \item `current_version` – the input version,
#'   \item `future_patch_version` – next patch version,
#'   \item `future_minor_version` – next minor version,
#'   \item `future_major_version` – next major version.
#' }
#'
#' @examples
#' get_different_future_version("1.2.3")
#'
#' @export
#' @importFrom desc description
#'
get_different_future_version <- function(version_number, verbose = TRUE) {
    all_versions <- c(current_version = version_number)

    tmp <- desc::description$new(text = paste0("Version: ", version_number))

    tmp$bump_version(which = 3L) |> invisible()
    all_versions <- c(
        all_versions,
        future_patch_version = tmp$get(keys = "Version") |> as.character()
    )
    if (verbose) {
        message("Future patch version: ", all_versions["future_patch_version"])
    }

    tmp$bump_version(which = 2L) |> invisible()
    all_versions <- c(
        all_versions,
        future_minor_version = tmp$get(keys = "Version") |> as.character()
    )
    if (verbose) {
        message("Future minor version: ", all_versions["future_minor_version"])
    }

    tmp$bump_version(which = 1L) |> invisible()
    all_versions <- c(
        all_versions,
        future_major_version = tmp$get(keys = "Version") |> as.character()
    )
    if (verbose) {
        message("Future major version: ", all_versions["future_major_version"])
    }

    return(all_versions)
}

#' @title Get package version from a GitHub branch
#'
#' @description
#' Retrieve the `Version` field from the DESCRIPTION file
#' of a GitHub repository at a specific branch.
#'
#' @inheritParams get_latest_version
#' @param branch [\link[base]{character}] Branch name (default: `"main"`).
#'
#' @return A single character string with the package version.
#'
#' @examples
#' \donttest{
#' get_version_from_branch("r-lib/usethis", branch = "main")
#' }
#'
#' @importFrom gh gh
#' @importFrom base64enc base64decode
#'
#' @keywords internal
#' @noRd
#'
get_version_from_branch <- function(
    gh_repo = file.path("rjdverse", "rjd3toolkit"),
    branch = "main",
    verbose = TRUE
) {
    description <- gh::gh(
        file.path("/repos", gh_repo, "contents", "DESCRIPTION"),
        ref = branch
    )
    if (verbose) {
        message("Fetched DESCRIPTION from branch: ", branch)
    }
    content <- rawToChar(base64enc::base64decode(description$content))
    nb_version <- read.dcf(textConnection(content))[, "Version"]
    if (verbose) {
        message("Version found on branch ", branch, ": ", nb_version)
    }
    return(nb_version)
}


#' @title Get package version from a local DESCRIPTION
#'
#' @description
#' Read the `Version` field from a local package DESCRIPTION file.
#'
#' @inheritParams change_remotes_field
#'
#' @return A single character string with the package version.
#'
#' @examples
#' path_rjd3workspace <- system.file("rjd3workspace", package = "releaser")
#'
#' get_version_from_local(path = path_rjd3workspace)
#'
#' @importFrom desc desc_get_version
#'
#' @keywords internal
#' @noRd
#'
get_version_from_local <- function(path = ".", verbose = TRUE) {
    version_number <- desc::desc_get_version(path) |> as.character()
    if (verbose) {
        message("Local version at '", path, "': ", version_number)
    }
    return(version_number)
}

#' @title Get latest GitHub release version
#'
#' @description
#' Retrieve the version number of the latest GitHub release for a repository
#' and optionally print versions found across all branches.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format
#' `"owner/repo"`.
#' @inheritParams change_remotes_field
#'
#' @return A character string with the version of the latest release.
#'
#' @examples
#' \donttest{
#' get_latest_version("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_latest_version <- function(
    gh_repo = file.path("rjdverse", "rjd3toolkit"),
    verbose = TRUE
) {
    release <- gh::gh(file.path("/repos", gh_repo, "releases", ref = "latest"))
    version_release <- get_version_from_branch(gh_repo, release$tag_name)
    if (verbose) {
        cat("Derni\u00e8re release :", version_release, "\n")
    }

    branches <- setdiff(
        get_github_branches(gh_repo),
        "gh-pages"
    )
    for (branche in branches) {
        try({
            version_number <- get_version_from_branch(gh_repo, branche)
            if (verbose) {
                cat("Version sur", branche, " :", version_number, "\n")
            }
        })
    }
    return(version_release)
}

#' @title Extract changelog entries for a given version
#'
#' @description
#' Extracts the section of `NEWS.md` corresponding to a given version.
#'
#' @inheritParams change_remotes_field
#' @inheritParams get_different_future_version
#'
#' @return A character string containing the formatted changelog for the given
#' version.
#'
#' @examples
#' path_rjd3workspace <- system.file("rjd3workspace", package = "releaser")
#'
#' get_changes(path = path_rjd3workspace, version_number = "Unreleased")
#' get_changes(path = path_rjd3workspace, version_number = "3.2.4")
#' get_changes(path = path_rjd3workspace, version_number = "3.5.1")
#'
#' @export
get_changes <- function(path = ".", version_number, verbose = TRUE) {
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
        stop("Version ", version_number, " doesn't exist for ", path)
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


#' @title List GitHub repository branches
#'
#' @description
#' Retrieve all branch names from a GitHub repository.
#'
#' @inheritParams get_latest_version
#'
#' @return A character vector with branch names.
#'
#' @examples
#' \donttest{
#' get_github_branches("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_github_branches <- function(
    gh_repo = file.path("rjdverse", "rjd3toolkit"),
    verbose = TRUE
) {
    if (verbose) {
        message("Fetching branches from repository: ", gh_repo)
    }
    res <- gh::gh("GET /repos/{repo}/branches", repo = gh_repo)
    branches <- vapply(res, function(x) x$name, FUN.VALUE = character(1L))
    if (verbose) {
        message("Found branches: ", toString(branches))
    }
    return(branches)
}
