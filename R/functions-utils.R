## Utility functions used across implementations.

#' Check for presence of files `expected` in `path`
#'
#' Used in:
#' - *R/XcmsExperimentFiles.R*: `validateAlabasterXcmsExperiment()`
#'
#' @noRd
.check_directory_content <- function(path, expected = character()) {
    if (any(miss <- !file.exists(file.path(path, expected))))
        stop("file(s) ", paste0("\"", expected[miss], "\"", collapse = ", "),
             " not found in ", path, call. = FALSE)
}

#' Check if the file `x` already exists and throw an error if that's TRUE
#'
#' Used in:
#' - *R/MsExperimentFiles.R*: `saveMsObject()` for `AlabasterParam` and
#'   `PlainTextParam`.
#'
#' @noRd
.check_overwriting <- function(x) {
    if (file.exists(x))
        stop("The provided path contains already an MS object stash. ",
             "Overwriting an existing stash is not supported. Please remove ",
             "the directory defined with parameter 'path' first.",
             call. = FALSE)
}

#' @importFrom jsonlite serializeJSON
#'
#' @importFrom jsonlite write_json
#'
#' @importFrom xcms processHistory
#'
#' @noRd
.export_process_history <- function(x, path = character()) {
    ph <- processHistory(x)
    write_json(serializeJSON(ph),
               file.path(path, "xcms_experiment_process_history.json"))
}

#' @importFrom jsonlite unserializeJSON
#'
#' @importFrom jsonlite read_json
#'
#' @noRd
.import_process_history <- function(x, path = character()) {
    fl <- file.path(path, "xcms_experiment_process_history.json")
    if (!file.exists(fl))
        stop("No \"xcms_experiment_process_history.json\" file found in ", path)
    ph <- unserializeJSON(read_json(fl)[[1L]])
    x@processHistory <- ph
    x
}
