test_that("get_version_from_branch errors clearly when the branch does not exist", {
    local_mocked_bindings(
        get_branches = function(gh_repo, verbose = FALSE) c("main", "develop")
    )

    expect_error(
        get_version_from_branch(gh_repo = "owner/repo", branch = "nope"),
        "Branch 'nope' does not exist in repository 'owner/repo'."
    )
})

test_that("get_version_from_branch skips the branch check when check_branch is FALSE", {
    local_mocked_bindings(
        get_branches = function(gh_repo, verbose = FALSE) {
            stop("get_branches should not be called")
        }
    )
    local_mocked_bindings(
        gh = function(...) stop("gh::gh should not be called"),
        .package = "gh"
    )

    expect_error(
        get_version_from_branch(
            gh_repo = "owner/repo",
            branch = "whatever",
            check_branch = FALSE
        ),
        "gh::gh should not be called"
    )
})
