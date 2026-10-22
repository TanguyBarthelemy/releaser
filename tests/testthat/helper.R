path_rjd3workspace_test <- testthat::test_path("data", "pkg_test")

initiate_tmp_test_dir <- function() {
    src <- file.path(path_rjd3workspace_test, "DESCRIPTION")
    tmp <- tempfile("releaser-desc-")
    dir.create(tmp)
    file.copy(src, file.path(tmp, "DESCRIPTION"))
    return(tmp)
}
