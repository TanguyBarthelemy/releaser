#' @title Compute possible future semantic versions
#'
#' @description
#' Given a current package version, compute the potential next
#' patch, minor, and major versions following semantic versioning rules.
#'
#' @param version [\link[base]{character}] Current version string (e.g. `"1.2.3"`).
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
get_different_future_version <- function(version) {
    all_versions <- c(current_version = version)

    tmp <- desc::description$new(text = paste0("Version: ", version))

    tmp$bump_version(which = 3L) |> invisible()
    all_versions <- c(all_versions, future_patch_version = tmp$get(keys = "Version") |> as.character())
    tmp$bump_version(which = 2L) |> invisible()
    all_versions <- c(all_versions, future_minor_version = tmp$get(keys = "Version") |> as.character())
    tmp$bump_version(which = 1L) |> invisible()
    all_versions <- c(all_versions, future_major_version = tmp$get(keys = "Version") |> as.character())

    return(all_versions)
}

#' @title Get package version from a GitHub branch
#'
#' @description
#' Retrieve the `Version` field from the DESCRIPTION file
#' of a GitHub repository at a specific branch.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format `"owner/repo"`.
#' @param branch [\link[base]{character}] Branch name (default: `"main"`).
#'
#' @return A single character string with the package version.
#'
#' @examples
#' \dontrun{
#' get_version_from_branch("r-lib/usethis", branch = "main")
#' }
#'
#' @importFrom gh gh
#' @importFrom base64enc base64decode
#' @keywords internal
get_version_from_branch <- function(gh_repo = file.path("rjdverse", "rjd3toolkit"), branch = "main") {
    description <- gh::gh(file.path("/repos", gh_repo, "contents", "DESCRIPTION"),
                          ref = branch)
    content <- rawToChar(base64enc::base64decode(description$content))
    nb_version <- read.dcf(textConnection(content))[, "Version"]
    return(nb_version)
}

#' @title Get package version from a local DESCRIPTION
#'
#' @description
#' Read the `Version` field from a local package DESCRIPTION file.
#'
#' @param path [\link[base]{character}] Path to a local package directory.
#'
#' @return A single character string with the package version.
#'
#' @examples
#' \dontrun{
#' get_version_from_local(".")
#' }
#'
#' @importFrom desc desc_get_version
#' @keywords internal
get_version_from_local <- function(path) {
    version_number <- desc::desc_get_version(path) |> as.character()
    return(version_number)
}

#' @title Get latest GitHub release version
#'
#' @description
#' Retrieve the version number of the latest GitHub release for a repository
#' and optionally print versions found across all branches.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository (`"owner/repo"`).
#' @param verbose [\link[base]{logical}] Whether to print information (default: `TRUE`).
#'
#' @return A character string with the version of the latest release.
#'
#' @examples
#' \dontrun{
#' get_latest_version("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_latest_version <- function(gh_repo = file.path("rjdverse", "rjd3toolkit"), verbose = TRUE) {
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
#' @param path [\link[base]{character}] Path to the package root directory.
#' @param version [\link[base]{character}] Version to extract (must exist in `NEWS.md`).
#'
#' @return A character string containing the formatted changelog for the given version.
#'
#' @examples
#' \dontrun{
#' get_changes(".", "1.0.0")
#' }
#'
#' @export
get_changes <- function(path, version) {
    changelog <- readLines(con = file.path(path, "NEWS.md"))

    starting_line <- grep(pattern = paste0("^## \\[", version, "\\]"), x = changelog) + 1L
    ending_line <- grep(pattern = "^## \\[", x = changelog)
    ending_line <- min(ending_line[ending_line > starting_line]) - 1L
    ref <- grep(pattern = paste0("^\\[", version, "\\]"), x = changelog)

    # Extraire les lignes du bloc
    changes <- changelog[starting_line:ending_line]

    # Remettre en forme
    return(paste(c("## Changes", changes, changelog[ref]), collapse = "\n"))
}

#' @title List GitHub repository branches
#'
#' @description
#' Retrieve all branch names from a GitHub repository.
#'
#' @param repo [\link[base]{character}] GitHub repository (`"owner/repo"`).
#'
#' @return A character vector with branch names.
#'
#' @examples
#' \dontrun{
#' get_github_branches("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_github_branches <- function(repo = file.path("rjdverse", "rjd3toolkit")) {
    res <- gh::gh("GET /repos/{repo}/branches", repo = repo)
    branches <- vapply(res, function(x) x$name, FUN.VALUE = character(1L))
    return(branches)
}
