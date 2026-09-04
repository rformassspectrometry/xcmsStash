
## file names for slots
.HDF5_FILE <- "hdf5_file"
.HDF5_MOD_COUNT <- "hdf5_mod_count"
.SAMPLE_ID <- "sample_id"
.CHROM_PEAKS_MS_LEVEL <- "chrom_peaks_ms_level"
.GAP_PEAKS_MS_LEVEL <- "gap_peaks_ms_level"
.FEATURES_MS_LEVEL <- "features_ms_level"

.PREF <- "xcms_experiment_hdf5_"
.HDF5_FILE_TXT <- paste0(.PREF, .HDF5_FILE, ".txt")
.HDF5_MOD_COUNT_TXT <- paste0(.PREF, .HDF5_MOD_COUNT, ".txt")
.SAMPLE_ID_TXT <- paste0(.PREF, .SAMPLE_ID, ".txt")
.CHROM_PEAKS_MS_LEVEL_TXT <- paste0(.PREF, .CHROM_PEAKS_MS_LEVEL, ".txt")
.GAP_PEAKS_MS_LEVEL_TXT <- paste0(.PREF, .GAP_PEAKS_MS_LEVEL, ".txt")
.FEATURES_MS_LEVEL_TXT <- paste0(.PREF, .FEATURES_MS_LEVEL, ".txt")

################################################################################
##    PlainTextParam
################################################################################

#' @rdname XcmsExperimentStash
setMethod(
    "saveMsObject", signature(object = "XcmsExperimentHdf5",
                              param = "PlainTextParam"),
    function(object, param, ...) {
        f <- getMethod("saveMsObject", c("MsExperiment", "PlainTextParam"))
        f(object, param, ...)
        p <- param@path
        file.copy(object@hdf5_file, file.path(p, basename(object@hdf5_file)))
        writeLines(basename(object@hdf5_file), file.path(p, .HDF5_FILE_TXT))
        writeLines(as.character(object@hdf5_mod_count),
                   file.path(p, .HDF5_MOD_COUNT_TXT))
        writeLines(object@sample_id, file.path(p, .SAMPLE_ID_TXT))
        writeLines(as.character(object@chrom_peaks_ms_level),
                   file.path(p, .CHROM_PEAKS_MS_LEVEL_TXT))
        writeLines(as.character(object@gap_peaks_ms_level),
                   file.path(p, .GAP_PEAKS_MS_LEVEL_TXT))
        writeLines(as.character(object@features_ms_level),
                   file.path(p, .FEATURES_MS_LEVEL_TXT))
        .write_process_history(object, param@path)
    })

#' @rdname XcmsExperimentStash
#'
#' @importFrom MsExperiment MsExperiment
setMethod(
    "readMsObject", signature(object = "XcmsExperimentHdf5",
                              param = "PlainTextParam"),
    function(object, param, ...) {
        f <- getMethod("readMsObject", c("MsExperiment", "PlainTextParam"))
        res <- as(f(MsExperiment(), param, ...), "XcmsExperimentHdf5")
        p <- param@path
        .check_directory_content(
            p, c(.HDF5_FILE_TXT, .HDF5_MOD_COUNT_TXT, .SAMPLE_ID_TXT,
                 .CHROM_PEAKS_MS_LEVEL_TXT, .GAP_PEAKS_MS_LEVEL_TXT,
                 .FEATURES_MS_LEVEL_TXT,"xcms_experiment_process_history.json"))
        res@hdf5_file <- file.path(
            p, readLines(file.path(p, .HDF5_FILE_TXT))[1L])
        res@hdf5_mod_count <- as.integer(
            readLines(file.path(p, .HDF5_MOD_COUNT_TXT))[1L])
        res@sample_id <- readLines(file.path(p, .SAMPLE_ID_TXT))
        res@chrom_peaks_ms_level <- as.integer(
            readLines( file.path(p, .CHROM_PEAKS_MS_LEVEL_TXT)))
        res@gap_peaks_ms_level <- as.integer(
            readLines(file.path(p, .GAP_PEAKS_MS_LEVEL_TXT)))
        res@features_ms_level <- as.integer(
            readLines(file.path(p, .FEATURES_MS_LEVEL_TXT)))
        res <- .load_process_history(res, param@path)
        validObject(res)
        res
    })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname XcmsExperimentStash
#'
#' @importClassesFrom xcms XcmsExperimentHdf5
setMethod("saveObject", "XcmsExperimentHdf5", function(x, path, ...) {
    altSaveObject(as(x, "MsExperiment"), path, ...)
    file.copy(x@hdf5_file, file.path(path, basename(x@hdf5_file)))
    altSaveObject(basename(x@hdf5_file), file.path(path, .HDF5_FILE))
    altSaveObject(x@hdf5_mod_count, file.path(path, .HDF5_MOD_COUNT))
    altSaveObject(x@sample_id, file.path(path, .SAMPLE_ID))
    altSaveObject(
        x@chrom_peaks_ms_level, file.path(path, .CHROM_PEAKS_MS_LEVEL))
    altSaveObject(x@gap_peaks_ms_level, file.path(path, .GAP_PEAKS_MS_LEVEL))
    altSaveObject(x@features_ms_level, file.path(path, .FEATURES_MS_LEVEL))
    .write_process_history(x, path)
    info <- readObjectFile(path)
    info$contains <- "ms_experiment"
    saveObjectFile(path, "xcms_experiment_hdf5", info)
})

validateAlabasterXcmsExperimentHdf5 <- function(path = character(),
                                                metadata = list()) {
    .check_directory_content(
        path, c(.HDF5_FILE, .HDF5_MOD_COUNT, .SAMPLE_ID, .CHROM_PEAKS_MS_LEVEL,
                .GAP_PEAKS_MS_LEVEL, .FEATURES_MS_LEVEL,
                "xcms_experiment_process_history.json"))
}

readAlabasterXcmsExperimentHdf5 <- function(path = character(),
                                            metadata = list(),
                                            ...) {
    validateAlabasterXcmsExperimentHdf5(path, metadata)
    metadata$type <- "ms_experiment"
    res <- altReadObject(path, metadata = metadata, ...)
    res <- as(res, "XcmsExperimentHdf5")
    res <- .load_process_history(res, path)
    res@hdf5_file <- file.path(
        path, altReadObject(file.path(path, .HDF5_FILE)))
    res@hdf5_mod_count <- altReadObject(file.path(path, .HDF5_MOD_COUNT))
    res@sample_id <- altReadObject(file.path(path, .SAMPLE_ID))
    res@chrom_peaks_ms_level <- altReadObject(
        file.path(path, .CHROM_PEAKS_MS_LEVEL))
    res@gap_peaks_ms_level <- altReadObject(
        file.path(path, .GAP_PEAKS_MS_LEVEL))
    res@features_ms_level <- altReadObject(
        file.path(path, .FEATURES_MS_LEVEL))
    validObject(res)
    res
}

#' @rdname XcmsExperimentStash
setMethod("saveMsObject", signature(object = "XcmsExperimentHdf5",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, param@path, ...)
          })

#' @rdname XcmsExperimentStash
setMethod("readMsObject", signature(object = "XcmsExperimentHdf5",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterXcmsExperimentHdf5(param@path, ...)
          })
