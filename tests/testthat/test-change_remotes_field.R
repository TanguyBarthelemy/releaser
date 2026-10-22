test_that("change_remotes_field rejects an invalid target", {
    tmp_path <- initiate_tmp_test_dir()
    on.exit(unlink(tmp_path, recursive = TRUE), add = TRUE)

    expect_error(
        change_remotes_field(path = tmp_path, target = "bogus"),
        "'arg' should be one of"
    )
})

test_that("change_remotes_field works", {
    tmp_path <- initiate_tmp_test_dir()
    on.exit(unlink(tmp_path, recursive = TRUE), add = TRUE)

    # develop
    new_remotes <- change_remotes_field(
        path = tmp_path,
        target = "develop"
    )
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
        expected = desc::desc_get_remotes(tmp_path)
    )

    # main
    new_remotes <- change_remotes_field(
        path = tmp_path,
        target = "main"
    )
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
        expected = desc::desc_get_remotes(tmp_path)
    )

    # snapshot
    new_remotes <- change_remotes_field(
        path = tmp_path,
        target = "snapshot"
    )
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
        expected = desc::desc_get_remotes(tmp_path)
    )
})

test_that("change_remotes_field normalizes the DESCRIPTION field order", {
    tmp_dir <- tempfile("releaser-change-remotes-")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)
    writeLines(
        c(
            "Package: normtest",
            "Title: Normalization Test",
            "Version: 1.0.0",
            "Description: Test package for remotes normalization.",
            "License: MIT + file LICENSE",
            "Encoding: UTF-8",
            "SystemRequirements: Java (>= 17)",
            "Imports: stats",
            "Remotes:",
            "    github::rjdverse/rjd3toolkit",
            "Config/testthat/edition: 3"
        ),
        con = file.path(tmp_dir, "DESCRIPTION")
    )

    change_remotes_field(path = tmp_dir, target = "develop", verbose = FALSE)

    before <- readLines(file.path(tmp_dir, "DESCRIPTION"))
    desc::desc_normalize(file = tmp_dir)
    expect_identical(before, readLines(file.path(tmp_dir, "DESCRIPTION")))
})
