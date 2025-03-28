
#' @export
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
