## Utility functions used across implementations.

#' @description
#'
#' Check for presence of files `expected` in `path`
#'
#' Used in:
#' - *R/XcmsExperiment.R*: `validateAlabasterXcmsExperiment()`
#' - *R/XcmsExperiment.R*: `readMsObject,XcmsExperiment,PlainTextParam`
#'
#' @noRd
.check_directory_content <- function(path, expected = character()) {
    if (any(miss <- !file.exists(file.path(path, expected))))
        stop("file(s) ", paste0("\"", expected[miss], "\"", collapse = ", "),
             " not found in ", path, call. = FALSE)
}

## #' @description
## #'
## #' Check if the file `x` already exists and throw an error if that's TRUE
## #'
## #' Used in:
## #' - *R/XcmsExperimentFiles.R*: `saveMsObject,XcmsExperiment,PlainTextParam`.
## #'
## #' @noRd
## .check_overwriting <- function(x) {
##     if (file.exists(x))
##         stop("The provided path contains already an MS object stash. ",
##              "Overwriting an existing stash is not supported. Please remove ",
##              "the directory defined with parameter 'path' first.",
##              call. = FALSE)
## }

#' @importFrom jsonlite serializeJSON
#'
#' @importFrom jsonlite write_json
#'
#' @importFrom xcms processHistory
#'
#' @description
#'
#' Used in:
#' - *R/XcmsExperiment.R*: `saveObject,XcmsExperiment,AlabasterParam`.
#'
#' @noRd
.write_process_history <- function(x, path = character()) {
    ph <- processHistory(x)
    write_json(serializeJSON(ph),
               file.path(path, "xcms_experiment_process_history.json"))
}

#' @importFrom jsonlite unserializeJSON
#'
#' @importFrom jsonlite read_json
#'
#' @description
#'
#' Used in:
#' - *R/XcmsExperriment.R*: `readAlabasterXcmsExperiment()`.
#'
#' @noRd
.load_process_history <- function(x, path = character()) {
    fl <- file.path(path, "xcms_experiment_process_history.json")
    if (!file.exists(fl))
        stop("No \"xcms_experiment_process_history.json\" file found in ",
             path, call. = FALSE)
    ph <- unserializeJSON(read_json(fl)[[1L]])
    x@processHistory <- ph
    x
}

#' @importMethodsFrom xcms chromPeaks
#'
#' @importMethodsFrom xcms chromPeakData
#'
#' @description
#'
#' Helper function to write chromatographic peak detection results from an
#' `XcmsExperiment` object to files in txt file format.
#'
#' @noRd
.txt_write_chrom_peaks <- function(x, path = character()) {
    write.table(chromPeaks(x),
                file = file.path(path, "xcms_experiment_chrom_peaks.txt"),
                sep = "\t")
    write.table(chromPeakData(x, return.type = "data.frame"), sep = "\t",
                file = file.path(path, "xcms_experiment_chrom_peak_data.txt"))
}

#' @importFrom utils read.table
#'
#' @description
#'
#' Load exported chromatographic peak information (in txt file format) into
#' the respective slots of the `XcmsExperiment` object `x`.
#'
#' @noRd
.txt_load_chrom_peaks <- function(x, path = character()) {
    f <- file.path(path, "xcms_experiment_chrom_peaks.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_chrom_peaks.txt\" file found in ",
             path, call. = FALSE)
    pk <- as.matrix(read.table(f, sep = "\t", header = TRUE))
    f <- file.path(path, "xcms_experiment_chrom_peak_data.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_chrom_peak_data.txt\" file found in ",
             path, call. = FALSE)
    pkd <- read.table(f, sep = "\t", header = TRUE)
    x@chromPeaks <- pk
    x@chromPeakData <- pkd
    x
}

#' @importFrom utils write.table
#'
#' @description
#'
#' Writes feature definitions of an `XcmsExperiment` to tab-delimited txt files,
#' one for the `featureDefinitions()` and one for the association between
#' features and chromatographic peaks (i.e., the `featureDefinitions()`'
#' `$peakidx` column).
#'
#' @noRd
.txt_write_features <- function(x, path = character()) {
    fts <- x@featureDefinitions
    pkidx <- data.frame(
        feature_index = rep(seq_len(nrow(fts)), lengths(fts$peakidx)),
        peak_index = unlist(fts$peakidx, use.names = FALSE))
    fts$peakidx <- NA
    write.table(
        fts, file = file.path(path, "xcms_experiment_feature_definitions.txt"),
        sep = "\t")
    write.table(
        pkidx, file = file.path(path, "xcms_experiment_feature_peak_index.txt"),
        sep = "\t")
}

#' @description
#'
#' Loads previously exported feature definitions from tab-delimited text files
#' into the provided `XcmsExperiment` object `x`.
#'
#' @noRd
.txt_load_features <- function(x, path = character()) {
    f <- file.path(path, "xcms_experiment_feature_definitions.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_feature_definitions.txt\" file found in ",
             path, call. = FALSE)
    fts <- read.table(f, sep = "\t", header = TRUE)
    f <- file.path(path, "xcms_experiment_feature_peak_index.txt")
    if (!file.exists(f))
        stop("No \"xcms_experiment_feature_peak_index.txt\" file found in ",
             path, call. = FALSE)
    pkidx <- read.table(f, sep = "\t", header = TRUE)
    fts$peakidx <- unname(split(pkidx$peak_index, pkidx$feature_index))
    x@featureDefinitions <- fts
    x
}
