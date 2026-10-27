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
#' @returns A named character vector with:
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

    suppressMessages(tmp$bump_version(which = 3L))
    all_versions <- c(
        all_versions,
        future_patch_version = tmp$get(keys = "Version") |> as.character()
    )
    if (verbose) {
        message("Future patch version: ", all_versions["future_patch_version"])
    }

    suppressMessages(tmp$bump_version(which = 2L))
    all_versions <- c(
        all_versions,
        future_minor_version = tmp$get(keys = "Version") |> as.character()
    )
    if (verbose) {
        message("Future minor version: ", all_versions["future_minor_version"])
    }

    suppressMessages(tmp$bump_version(which = 1L))
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
#' @param check_branch [\link[base]{logical}] Whether to check that the
#'   branch exists in the repository before fetching it (default: `TRUE`).
#'   Set to `FALSE` when the branch is already known to exist, to avoid an
#'   extra GitHub API call.
#'
#' @returns A single character string with the package version.
#'
#' @examplesIf FALSE
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
    gh_repo = file.path("r-lib", "usethis"),
    branch = "main",
    verbose = TRUE,
    check_branch = TRUE
) {
    if (check_branch && !branch %in% get_branches(gh_repo)) {
        stop(
            "Branch '",
            branch,
            "' does not exist in repository '",
            gh_repo,
            "'.",
            call. = FALSE
        )
    }
    description <- gh::gh(
        file.path("/repos", gh_repo, "contents", "DESCRIPTION"),
        ref = branch
    )
    if (verbose) {
        message("Fetched DESCRIPTION from branch: ", branch)
    }
    content <- rawToChar(base64enc::base64decode(description$content))
    nb_version <- as.character(
        desc::description$new(text = content)$get("Version")
    )
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
#' @inheritParams set_latest_rjdverse_version
#'
#' @returns A single character string with the package version.
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
get_version_from_local <- function(path, verbose = TRUE) {
    version_number <- desc::desc_get_version(path) |> as.character()
    if (verbose) {
        message("Local version at '", path, "': ", version_number)
    }
    return(version_number)
}

#' Get the tag of the latest GitHub release
#'
#' Retrieve the tag name of the latest GitHub release of a repository.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format
#' `"owner/repo"`.
#'
#' @returns A character string with the release tag name, or `NA` when the
#' repository has no release.
#'
#' @keywords internal
#' @noRd
#'
get_latest_release_tag <- function(gh_repo) {
    release <- tryCatch(
        gh::gh(file.path("/repos", gh_repo, "releases", "latest")),
        http_error_404 = function(e) NULL
    )
    if (is.null(release)) {
        return(NA_character_)
    }
    return(release$tag_name)
}

#' Get the default branch of a GitHub repository
#'
#' Retrieve the name of the default branch of a repository.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format
#' `"owner/repo"`.
#'
#' @returns A character string with the default branch name.
#'
#' @keywords internal
#' @noRd
#'
get_default_branch <- function(gh_repo) {
    repo <- gh::gh(file.path("/repos", gh_repo))
    return(repo$default_branch)
}

#' @title Get latest GitHub release version
#'
#' @description
#' Retrieve the version number of the latest GitHub release for a repository
#' and optionally print versions found across all branches. When the
#' repository has no release, the version of the default branch is returned
#' instead.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format
#' `"owner/repo"`.
#' @param max_branches [\link[base]{integer}] Maximum number of branches to
#'   inspect, to limit the number of GitHub API calls
#'   (default: `50L`).
#' @inheritParams change_remotes_field
#'
#' @returns A character string with the version of the latest release, or of
#' the default branch when the repository has no release.
#'
#' @examplesIf FALSE
#' \donttest{
#' get_latest_version("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_latest_version <- function(
    gh_repo = file.path("r-lib", "usethis"),
    max_branches = 50L,
    verbose = TRUE
) {
    release_tag <- get_latest_release_tag(gh_repo)
    if (is.na(release_tag)) {
        branch <- get_default_branch(gh_repo)
        if (verbose) {
            message(
                "No release found; using the version from the default branch (",
                branch,
                ")."
            )
        }
        version_release <- get_version_from_branch(
            gh_repo,
            branch,
            verbose = verbose,
            check_branch = FALSE
        )
    } else {
        version_release <- get_version_from_branch(
            gh_repo,
            release_tag,
            verbose = verbose,
            check_branch = FALSE
        )
        if (verbose) {
            message("Latest release: ", version_release)
        }
    }

    branches <- setdiff(
        get_branches(gh_repo, verbose = verbose),
        c("gh-pages", "badges")
    )
    if (length(branches) > max_branches) {
        if (verbose) {
            message(
                "Limiting to the first ",
                max_branches,
                " of ",
                length(branches),
                " branches."
            )
        }
        branches <- branches[seq_len(max_branches)]
    }
    for (branch in branches) {
        version_number <- tryCatch(
            get_version_from_branch(
                gh_repo,
                branch,
                verbose = verbose,
                check_branch = FALSE
            ),
            error = function(e) NULL
        )
        if (is.null(version_number)) {
            if (verbose) {
                message(
                    "Could not read the DESCRIPTION of branch ",
                    branch,
                    "."
                )
            }
            next
        }
        if (verbose) {
            message("Version on branch ", branch, ": ", version_number)
        }
    }
    return(version_release)
}

#' List GitHub repository branches
#'
#' Retrieve all branch names from a GitHub repository.
#'
#' @param gh_repo [\link[base]{character}] GitHub repository in the format
#' `"owner/repo"`.
#' @param verbose [\link[base]{logical}] Whether to print additional
#' information (default: `FALSE`).
#'
#' @returns A character vector with branch names.
#'
#' @keywords internal
#' @noRd
#'
get_branches <- function(gh_repo, verbose = FALSE) {
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

#' @title List GitHub repository branches
#'
#' @description
#' Retrieve all branch names from a GitHub repository.
#'
#' @inheritParams get_latest_version
#'
#' @returns A character vector with branch names.
#'
#' @examplesIf FALSE
#' \donttest{
#' get_github_branches("r-lib/usethis")
#' }
#'
#' @importFrom gh gh
#' @export
get_github_branches <- function(
    gh_repo = file.path("r-lib", "usethis"),
    verbose = TRUE
) {
    return(get_branches(gh_repo, verbose = verbose))
}
