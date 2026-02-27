read_documentation <- function(pkg_dir) {
    r_files <- list.files(file.path(pkg_dir, "R"), full.names = TRUE, pattern = "\\.R$", recursive = TRUE)
    blocks <- lapply(r_files, roxygen2::parse_file)
    blocks <- unlist(blocks, recursive = FALSE)
    class(blocks) <- "docblock"
    return(blocks)
}

# Fonctions utiles
`%ino%` <- function(x, table) {
    UseMethod("%ino%", table)
}

#' @exportS3Method `%ino%` list
#' @method `%ino%` list
`%ino%.list` <- function(x, table) {
    sapply(table, `%ino%`, x = x)
}

#' @exportS3Method `%ino%` default
#' @method `%ino%` default
`%ino%.default` <- function(x, table) {
    base::`%in%`(x, table)
}

get_tag <- function(x) {
    UseMethod("get_tag", x)
}

#' @exportS3Method get_tag roxy_block
#' @method get_tag roxy_block
get_tag.roxy_block <- function(x) {
    sapply(x$tags, base::`[[`, "tag")
}

#' @exportS3Method get_tag docblock
#' @method get_tag docblock
get_tag.docblock <- function(x) {
    lapply(x, FUN = get_tag)
}

get_examples <- function(x) {
    UseMethod("get_examples", x)
}

#' @exportS3Method get_examples roxy_block
#' @method get_examples roxy_block
get_examples.roxy_block <- function(x) {
    if (!has_examples(x)) {
        return("")
    }

    id_tag_example <- which(get_tag(x) %ino% c("examplesIf", "examples"))
    example <- paste(
        vapply(
            X = id_tag_example,
            FUN = function(k) x$tags[[k]]$val,
            FUN.VALUE = character(1L)
        ),
        collapse = "\n"
    )
    return(example)

}

#' @exportS3Method get_examples docblock
#' @method get_examples docblock
get_examples.docblock <- function(x) {
    vapply(x, get_examples, character(1L))
}

get_topics <- function(x) {
    UseMethod("get_topics", x)
}

#' @exportS3Method get_topics roxy_block
#' @method get_topics roxy_block
get_topics.roxy_block <- function(x) {
    topic <- x$object$topic
    if (is.null(topic)) return("")
    return(topic)
}

#' @exportS3Method get_topics docblock
#' @method get_topics docblock
get_topics.docblock <- function(x) {
    if (length(x) == 0L) return(NULL)
    sapply(x, FUN = get_topics)
}

is_not_in_example <- function(x, all_examples) {
    UseMethod("is_not_in_example", x)
}

#' @exportS3Method is_not_in_example roxy_block
#' @method is_not_in_example roxy_block
is_not_in_example.roxy_block <- function(x, all_examples) {
    if (missing(all_examples)) {
        stop("All examples are missing")
    }
    topics <- get_topics(x)
    if (is.null(topics)) {
        return(FALSE)
    }
    !(grepl(pattern = topics, x = all_examples, fixed = TRUE) |> any())
}

#' @exportS3Method is_not_in_example docblock
#' @method is_not_in_example docblock
is_not_in_example.docblock <- function(x, all_examples) {
    if (missing(all_examples)) {
        all_examples <- get_examples(x)
    }
    sapply(x, FUN = is_not_in_example, all_examples = all_examples)
}

has_tag <- function(x, tag) {
    tag %ino% get_tag(x)
}
is_exported <- function(x) {
    has_tag(x, "export")
}
has_return <- function(x) {
    has_tag(x, "return")
}
has_returns <- function(x) {
    has_tag(x, "returns")
}
has_examples <- function(x) {
    has_tag(x, "examplesIf") | has_tag(x, "examples")
}
has_describeIn <- function(x) {
    has_tag(x, "describeIn")
}
has_title <- function(x) {
    has_tag(x, "title")
}
has_rdname <- function(x) {
    has_tag(x, "rdname")
}

is_call <- function(x){
    UseMethod("is_call", x)
}

#' @exportS3Method is_call roxy_block
#' @method is_call roxy_block
is_call.roxy_block <- function(x){
    return(!is.null(x$call) && x$call != "_PACKAGE")
}

#' @exportS3Method is_call docblock
#' @method is_call docblock
is_call.docblock <- function(x){
    sapply(x, is_call)
}

is_jd3_utilities <- function(x) {
    UseMethod("is_jd3_utilities", x)
}

#' @exportS3Method is_jd3_utilities roxy_block
#' @method is_jd3_utilities roxy_block
is_jd3_utilities.roxy_block <- function(x) {
    tag_list <- get_tag(x)
    id <- which("rdname" == tag_list)
    if (length(id) > 0) {
        return(x$tags[[id]]$raw == "jd3_utilities")
    }
    return(FALSE)
}

#' @exportS3Method is_jd3_utilities docblock
#' @method is_jd3_utilities docblock
is_jd3_utilities.docblock <- function(x) {
    sapply(x, is_jd3_utilities)
}

#' @exportS3Method `[` docblock
#' @method `[` docblock
`[.docblock` <- function(x, ..., drop) {
    output <- NextMethod("[", object = x)
    class(output) <- "docblock"
    return(output)
}

get_no_s3_method <- function(x) {
    x[!grepl("^[^\\.]+\\.", x, fixed = FALSE)]
}

display_functions <- function(x) {
    if (length(x) > 0L) {
        cat("- [ ] `", paste(sort(x), collapse = "()`\n- [ ] `"), "()`\n", sep = "")
    }
    return(invisible(NULL))
}

#' @title Check for missing or deprecated documentation tag
#'
#' @description
#' [check_missing_examples_tag()] Identifies exported functions that do not
#' declare any `@examples` (or `@examplesIf`) tag in their roxygen2
#' documentation.
#' [check_missing_examples_content()] detects exported functions that declare an
#' `@examples` tag but whose examples are not actually present in the combined
#' example blocks.
#' [check_missing_title()] identifies exported functions that do not define a
#' `@title` tag in their documentation.
#' [check_describeIn_usage()] lists all documented topics using the
#' `@describeIn` tag.
#' [check_return_tag_usage()] identifies functions still using `@return`.
#' [check_missing_returns()] identifies exported functions that do not declare a
#' `@returns` tag.
#'
#' @param pkg_dir Path to the R package.
#'
#' @details
#' The `@describeIn` tag is generally discouraged in modern roxygen2 workflows.
#' The `@return` tag is superseded by `@returns`.
#'
#' @name check
#' @returns A character vector of function names
#'
#' @export
check_missing_examples_tag <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    list_funs <- blocks |>
        Filter(f = Negate(has_examples)) |>
        Filter(f = Negate(has_rdname)) |>
        Filter(f = is_call) |>
        Filter(f = is_exported) |>
        get_topics() |>
        get_no_s3_method()

    return(list_funs)
}

#' @rdname check
#' @export
check_missing_examples_content <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    missing_examples_tag <- check_missing_examples_tag(pkg_dir)

    list_funs <- blocks |>
        Filter(f = \(x) is_not_in_example(x, all_examples = get_examples(blocks))) |>
        Filter(f = is_exported) |>
        Filter(f = is_call) |>
        get_topics() |>
        get_no_s3_method() |>
        setdiff(y = missing_examples_tag)

    return(list_funs)
}

#' @rdname check
#' @export
check_missing_title <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    list_funs <- blocks |>
        Filter(f = Negate(has_title)) |>
        Filter(f = Negate(has_describeIn)) |>
        Filter(f = Negate(has_rdname)) |>
        Filter(f = is_exported) |>
        Filter(f = is_call) |>
        get_topics()

    return(list_funs)
}

#' @rdname check
#' @export
check_describeIn_usage <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    list_funs <- blocks |>
        Filter(f = has_describeIn) |>
        Filter(f = is_call) |>
        get_topics()

    return(list_funs)
}

#' @rdname check
#' @export
check_return_tag_usage <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    blocks |>
        Filter(f = has_return) |>
        Filter(f = is_call) |>
        get_topics()
}

#' @rdname check
#' @export
check_missing_returns <- function(pkg_dir) {
    blocks <- read_documentation(pkg_dir)

    blocks |>
        Filter(f = is_exported) |>
        Filter(f = Negate(has_returns)) |>
        Filter(f = Negate(has_describeIn)) |>
        Filter(f = Negate(has_rdname)) |>
        Filter(f = is_call) |>
        get_topics()
}

#' @title Check R package documentation
#'
#' @description
#' Performs a series of documentation consistency checks on a package
#' using roxygen2 parsed blocks.
#'
#' The following checks are performed:
#' - Missing `@examples` tag in exported functions
#' - Missing example content
#' - Missing `@title`
#' - Usage of discouraged `@describeIn`
#' - Usage of deprecated `@return`
#' - Missing `@returns`
#'
#' @inheritParams check
#' @param verbose Logical. If `TRUE`, prints a formatted summary.
#' @param error_on_fail Logical. If `TRUE`, stops execution if any issue is found.
#'
#' @return An object of class `"releaser_doc_check"` containing
#' a named list of detected issues.
#' @export
check_docs <- function(pkg_dir = ".", verbose = interactive(), error_on_fail = FALSE) {

    if (!dir.exists(pkg_dir)) {
        stop("`pkg_dir` does not exist.")
    }

    blocks <- read_documentation(pkg_dir)

    results <- list(
        missing_examples_tag = check_missing_examples_tag(pkg_dir),
        missing_examples_content = check_missing_examples_content(pkg_dir),
        missing_title = check_missing_title(pkg_dir),
        describeIn_usage = check_describeIn_usage(pkg_dir),
        deprecated_return_tag = check_return_tag_usage(pkg_dir),
        missing_returns = check_missing_returns(pkg_dir)
    )

    class(results) <- "releaser_doc_check"

    if (verbose) {
        print(results)
    }

    if (error_on_fail && any(lengths(results) > 0L)) {
        stop("Documentation issues detected. See output above.", call. = FALSE)
    }

    return(invisible(results))
}

#' @export
print.releaser_doc_check <- function(x, ...) {

    cat("Documentation checks\n")
    cat("====================\n\n")

    for (nm in names(x)) {
        issues <- x[[nm]]
        cat("*", nm, ":\n")
        if (length(issues) == 0L) {
            cat("  ✓ OK\n\n")
        } else {
            display_functions(issues)
            cat("\n")
        }
    }

    return(invisible(x))
}
