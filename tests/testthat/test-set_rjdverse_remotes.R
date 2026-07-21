test_that("set_rjdverse_remotes works", {
    new_remotes <- set_rjdverse_remotes(path = path_rjd3workspace)
    expect_identical(
        object = new_remotes,
        expected = c(
            "github::rjdverse/rjd3providers",
            "github::rjdverse/rjd3toolkit",
            "github::rjdverse/rjd3tramoseats",
            "github::rjdverse/rjd3x13"
        )
    )
    expect_identical(
        object = new_remotes,
        expected = desc::desc_get_remotes(path_rjd3workspace)
    )
})
