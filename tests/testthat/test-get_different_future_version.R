test_that("multiplication works", {
    expected_output <- c(
        current_version = "1.2.3",
        future_patch_version = "1.2.4",
        future_minor_version = "1.3.0",
        future_major_version = "2.0.0"
    )
    expect_identical(
        object = get_different_future_version("1.2.3"),
        expected = expected_output
    )
    expect_message(object = get_different_future_version("1.2.3", verbose = TRUE))
    # expect_no_message(object = {get_different_future_version("1.2.3", verbose = FALSE)})
})
