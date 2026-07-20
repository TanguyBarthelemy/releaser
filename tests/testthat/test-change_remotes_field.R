test_that("change_remotes_field works", {
    # develop
    new_remotes <- change_remotes_field(path = path_rjd3workspace,
                                        target = "develop")
    expect_identical(
        object = new_remotes,
        expected = c(
            "github::rjdverse/rjd3providers@develop",
            "github::rjdverse/rjd3toolkit@develop",
            "github::rjdverse/rjd3tramoseats@develop",
            "github::rjdverse/rjd3x13@develop"
        )
    )
    expect_identical(
        object = new_remotes,
        expected = desc::desc_get_remotes(path_rjd3workspace)
    )

    # main
    new_remotes <- change_remotes_field(path = path_rjd3workspace,
                                        target = "main")
    expect_identical(
        object = new_remotes,
        expected = c(
            "github::rjdverse/rjd3providers@*release",
            "github::rjdverse/rjd3toolkit@*release",
            "github::rjdverse/rjd3tramoseats@*release",
            "github::rjdverse/rjd3x13@*release"
        )
    )
    expect_identical(
        object = new_remotes,
        expected = desc::desc_get_remotes(path_rjd3workspace)
    )

    # snapshot
    new_remotes <- change_remotes_field(path = path_rjd3workspace,
                                        target = "snapshot")
    expect_identical(
        object = new_remotes,
        expected = c(
            "github::rjdverse/rjd3providers@snapshot",
            "github::rjdverse/rjd3toolkit@snapshot",
            "github::rjdverse/rjd3tramoseats@snapshot",
            "github::rjdverse/rjd3x13@snapshot"
        )
    )
    expect_identical(
        object = new_remotes,
        expected = desc::desc_get_remotes(path_rjd3workspace)
    )
})
