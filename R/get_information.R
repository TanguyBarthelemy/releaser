
#' @export
#' @importFrom desc description
#'
get_different_future_version <- function(path) {

    all_versions <- NULL
    all_versions <- c(all_versions, current_version = desc::desc_get_version(path) |> as.character())

    tmp <- desc::description$new(path)
    tmp$bump_version(which = 3) |> invisible()
    all_versions <- c(all_versions, future_patch_version = tmp$get(keys = "Version") |> as.character())
    tmp$bump_version(which = 2) |> invisible()
    all_versions <- c(all_versions, future_minor_version = tmp$get(keys = "Version") |> as.character())
    tmp$bump_version(which = 1) |> invisible()
    all_versions <- c(all_versions, future_major_version = tmp$get(keys = "Version") |> as.character())

    return(all_versions)
}

#' @importFrom gh gh
#' @importFrom base64enc base64decode
get_version_from_branch <- function(gh_repo, branch) {
    description <- gh::gh(paste0("/repos/", gh_repo, "/contents/DESCRIPTION"),
                          ref = branch)
    content <- rawToChar(base64enc::base64decode(description$content))
    nb_version <- read.dcf(textConnection(content))[, "Version"]
    return(nb_version)
}

#' @importFrom gh gh
#' @export
get_latest_version <- function(gh_repo = "rjdverse/rjd3toolkit", verbose = TRUE) {

    # Version sur main
    release <- gh::gh(paste0("/repos/", gh_repo, "/releases/latest"))
    version_main <- get_version_from_branch(gh_repo, release$tag_name)

    # Version sur main
    version_release <- get_version_from_branch(gh_repo, "main")

    # Version sur develop
    version_develop <- get_version_from_branch(gh_repo, "develop")

    # Summary
    if (verbose) {
        cat("Derni\u00e8re release :", version_release, "\n")
        cat("Version sur main :", version_main, "\n")
        cat("Version sur develop :", version_develop, "\n")
    }

    if (version_release != version_main) {
        stop("main branch of ", gh_repo, " doesn't have the same version as release.")
    }

    return(version_release)
}

