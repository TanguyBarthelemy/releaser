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

test_that("set_rjdverse_remotes honours the org and prefix arguments", {
    src <- testthat::test_path("data", "DESCRIPTION")
    tmp <- tempfile("releaser-desc-")
    dir.create(tmp)
    file.copy(src, file.path(tmp, "DESCRIPTION"))
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    remotes <- set_rjdverse_remotes(
        path = file.path(tmp, "DESCRIPTION"),
        org = "myorg",
        prefix = "rjd3",
        verbose = FALSE
    )
    expect_identical(
        remotes,
        c(
            "github::myorg/rjd3providers",
            "github::myorg/rjd3toolkit",
            "github::myorg/rjd3tramoseats",
            "github::myorg/rjd3x13"
        )
    )
})

test_that("set_latest_deps_version honours the org and prefix arguments", {
    src <- testthat::test_path("data", "DESCRIPTION")
    tmp <- tempfile("releaser-desc-")
    dir.create(tmp)
    file.copy(src, file.path(tmp, "DESCRIPTION"))
    on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

    local_mocked_bindings(
        get_latest_version = function(
            gh_repo,
            max_branches = 50L,
            verbose = TRUE
        ) {
            expect_true(startsWith(gh_repo, "myorg/rjd3"))
            "9.9.9"
        }
    )

    set_latest_deps_version(
        path = file.path(tmp, "DESCRIPTION"),
        org = "myorg",
        prefix = "rjd3",
        verbose = FALSE
    )

    deps <- desc::desc_get_deps(file.path(tmp, "DESCRIPTION"))
    rjd_deps <- deps[
        deps$package %in%
            c("rjd3providers", "rjd3toolkit", "rjd3tramoseats", "rjd3x13"),
    ]
    expect_equal(nrow(rjd_deps), 4L)
    expect_true(all(rjd_deps$version == ">= 9.9.9"))
})
