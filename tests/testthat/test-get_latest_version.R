test_that("get_latest_version returns the release version", {
    local_mocked_bindings(
        get_latest_release_tag = function(gh_repo) "v1.2.3",
        get_branches = function(gh_repo, verbose = FALSE) c("main", "develop"),
        get_version_from_branch = function(
            gh_repo,
            branch = "main",
            verbose = TRUE
        ) {
            if (branch == "v1.2.3") {
                "1.2.3"
            } else {
                "1.3.0.9000"
            }
        }
    )

    version <- expect_silent(
        get_latest_version(gh_repo = "owner/repo", verbose = FALSE)
    )
    expect_identical(version, "1.2.3")
})

test_that("get_latest_version reports the versions of all branches", {
    local_mocked_bindings(
        get_latest_release_tag = function(gh_repo) "v1.2.3",
        get_branches = function(gh_repo, verbose = FALSE) c("main", "develop"),
        get_version_from_branch = function(
            gh_repo,
            branch = "main",
            verbose = TRUE
        ) {
            if (branch == "v1.2.3") {
                "1.2.3"
            } else {
                "1.3.0.9000"
            }
        }
    )

    expect_message(
        get_latest_version(gh_repo = "owner/repo", verbose = TRUE),
        "Latest release: 1.2.3"
    )
    expect_message(
        get_latest_version(gh_repo = "owner/repo", verbose = TRUE),
        "Version on branch develop: 1.3.0.9000"
    )
})

test_that("get_latest_version skips branches whose DESCRIPTION cannot be read", {
    local_mocked_bindings(
        get_latest_release_tag = function(gh_repo) "v1.2.3",
        get_branches = function(gh_repo, verbose = FALSE) c("main", "broken"),
        get_version_from_branch = function(
            gh_repo,
            branch = "main",
            verbose = TRUE
        ) {
            if (branch == "broken") {
                stop("Not Found")
            }
            "1.2.3"
        }
    )

    expect_message(
        get_latest_version(gh_repo = "owner/repo", verbose = TRUE),
        "Could not read the DESCRIPTION of branch broken."
    )
    version <- expect_silent(
        get_latest_version(gh_repo = "owner/repo", verbose = FALSE)
    )
    expect_identical(version, "1.2.3")
})

test_that("get_latest_version ignores the gh-pages branch", {
    local_mocked_bindings(
        get_latest_release_tag = function(gh_repo) "v1.2.3",
        get_branches = function(gh_repo, verbose = FALSE) c("main", "gh-pages"),
        get_version_from_branch = function(
            gh_repo,
            branch = "main",
            verbose = TRUE
        ) {
            if (branch == "gh-pages") {
                stop("Not Found")
            }
            "1.2.3"
        }
    )

    messages <- character(0)
    withCallingHandlers(
        get_latest_version(gh_repo = "owner/repo", verbose = TRUE),
        message = function(m) {
            messages <<- c(messages, conditionMessage(m))
            invokeRestart("muffleMessage")
        }
    )
    expect_false(any(grepl("gh-pages", messages, fixed = TRUE)))
})

test_that("get_latest_version does not call the deprecated get_github_branches (#60)", {
    local_mocked_bindings(
        get_latest_release_tag = function(gh_repo) "v1.2.3",
        get_branches = function(gh_repo, verbose = FALSE) c("main"),
        get_version_from_branch = function(
            gh_repo,
            branch = "main",
            verbose = TRUE
        ) "1.2.3",
        get_github_branches = function(...) {
            stop("get_github_branches should not be called")
        }
    )

    expect_no_warning(
        get_latest_version(gh_repo = "owner/repo", verbose = TRUE)
    )
})
