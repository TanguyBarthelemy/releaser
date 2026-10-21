bad_pkg_lines <- c(
    "#' @title A well documented function",
    "#'",
    "#' @description Does something.",
    "#'",
    "#' @param x A number.",
    "#' @returns A number.",
    "#' @examples",
    "#' good_fun(1)",
    "#' @export",
    "good_fun <- function(x) x",
    "",
    "#' @description No title, no examples, no returns.",
    "#' @export",
    "bad_fun <- function(x) x",
    "",
    "#' @title Examples do not reference the function",
    "#' @returns A number.",
    "#' @examples",
    "#' unrelated_call()",
    "#' @export",
    "ghost_fun <- function(x) x",
    "",
    "#' @title Uses the discouraged describeIn tag",
    "#' @describeIn good_fun Another topic.",
    "#' @examples",
    "#' alias_fun(1)",
    "#' @export",
    "alias_fun <- function(x) x",
    "",
    "#' @title Uses the deprecated return tag",
    "#' @return A number.",
    "#' @examples",
    "#' old_return_fun(1)",
    "#' @export",
    "old_return_fun <- function(x) x",
    "",
    "#' @title An S3 method that should be ignored",
    "#' @returns A number.",
    "#' @examples",
    "#' print.myclass(1)",
    "#' @export",
    "#' @exportS3Method print myclass",
    "print.myclass <- function(x, ...) x"
)

clean_pkg_lines <- c(
    "#' @title A well documented function",
    "#'",
    "#' @description Does something.",
    "#'",
    "#' @param x A number.",
    "#' @returns A number.",
    "#' @examples",
    "#' good_fun(1)",
    "#' @export",
    "good_fun <- function(x) x"
)

new_fake_pkg <- function(lines) {
    dir <- tempfile("releaser-test-")
    dir.create(file.path(dir, "R"), recursive = TRUE)
    writeLines(text = lines, con = file.path(dir, "R", "fake.R"))
    return(dir)
}

test_that("check_missing_examples_tag detects exported functions without examples", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_missing_examples_tag(dir), "bad_fun")
})

test_that("check_missing_examples_content detects examples that do not use the function", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_missing_examples_content(dir), "ghost_fun")
})

test_that("check_missing_examples_content requires the function to be called", {
    lines <- c(
        "#' @title Function whose name is a substring of another call",
        "#' @returns A number.",
        "#' @examples",
        "#' check_docs(1)",
        "#' @export",
        "check <- function(x) x",
        "",
        "#' @title Another function",
        "#' @returns A number.",
        "#' @examples",
        "#' check_docs(1)",
        "#' @export",
        "check_docs <- function(x) x"
    )
    dir <- new_fake_pkg(lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_missing_examples_content(dir), "check")
})

test_that("check_missing_title detects exported functions without a title", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_missing_title(dir), "bad_fun")
})

test_that("check_describeIn_usage detects the use of describeIn", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_describeIn_usage(dir), "alias_fun")
})

test_that("check_return_tag_usage detects the deprecated return tag", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(check_return_tag_usage(dir), "old_return_fun")
})

test_that("check_missing_returns detects exported functions without a returns tag", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_identical(
        check_missing_returns(dir),
        c("bad_fun", "old_return_fun")
    )
})

test_that("checks also accept a docblock object", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    blocks <- releaser:::read_documentation(dir)
    expect_s3_class(blocks, "docblock")

    expect_identical(check_missing_examples_tag(blocks), "bad_fun")
    expect_identical(check_missing_examples_content(blocks), "ghost_fun")
    expect_identical(check_missing_title(blocks), "bad_fun")
    expect_identical(check_describeIn_usage(blocks), "alias_fun")
    expect_identical(check_return_tag_usage(blocks), "old_return_fun")
    expect_identical(
        check_missing_returns(blocks),
        c("bad_fun", "old_return_fun")
    )
})

test_that("S3 methods are ignored by the checks", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    result <- check_docs(dir)
    expect_false("print.myclass" %in% unlist(result))
})

test_that("check_docs returns a releaser_doc_check object", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    result <- expect_invisible(check_docs(dir))
    expect_s3_class(result, "releaser_doc_check")
    expect_named(
        result,
        c(
            "missing_examples_tag",
            "missing_examples_content",
            "missing_title",
            "describeIn_usage",
            "deprecated_return_tag",
            "missing_returns"
        )
    )
    expect_identical(result$missing_examples_tag, "bad_fun")
    expect_identical(result$missing_examples_content, "ghost_fun")
})

test_that("check_docs passes on a fully documented package", {
    dir <- new_fake_pkg(clean_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    result <- check_docs(dir, error_on_fail = TRUE)
    expect_true(all(lengths(result) == 0L))
})

test_that("check_docs stops when error_on_fail is TRUE and issues exist", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    expect_error(check_docs(dir, error_on_fail = TRUE))
})

test_that("check_docs errors when the package directory does not exist", {
    expect_error(
        check_docs("/definitely/not/a/real/path"),
        "does not exist"
    )
})

test_that("print method displays the detected issues", {
    dir <- new_fake_pkg(bad_pkg_lines)
    on.exit(unlink(dir, recursive = TRUE), add = TRUE)

    result <- check_docs(dir)
    expect_output(print(result), "Documentation checks")
    expect_output(
        print(result),
        "- [ ] `bad_fun()`",
        fixed = TRUE
    )
})
