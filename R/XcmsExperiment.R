#' @title `XcmsExperiment` Stash
#'
#' @name XcmsExperimentStash
#'
#' @description
#'
#' [xcms::XcmsExperiment] or [xcms::XcmsExperimentHdf5] *xcms* result objects
#' can be stored to (or read from) *XcmsExperimentStash*es using the
#' `saveMsObject()` and `readMsObject()` functions which take a second argument
#' `parameter` to select and configure the format of the stash. The xcmsStash
#' extends the [MsExperimentStash::MsExperimentStash] defined in the
#' *MsExperimentStash* package, i.e., it shares the same content, but adds the
#' *xcms* preprocessing results to it. A self-contained, portable, stash can
#' be created by passing `consolidate = TRUE` to the `saveMsObject()`
#' (or `saveObject()`) call. This will ensure that also the data files for the
#' full MS data are stored within the stash folder (resulting in an eventually
#' much larger stash folder size).
#'
#' The supported stash formats are listed in the sections below.
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' This alabster stash format is the most complete and reliable way for
#' long-term (and portable) storage of an `XcmsExperiment` or
#' `XcmsExperimentHdf5` object.
#' Objects can be saved or read from this stash format either using the
#' `saveMsObject()` and `readMsObject()` functions together with an
#' `AlabasterParam` object or also using the [alabaster.base::saveObject()] and
#' [alabaster.base::readObject()] functions from the *alabaster.base* package.
#' The alabaster stash format for `XcmsExperiment` and `XcmsExperimentHdf5`
#' objects extends the [MsExperimentStash::MsExperimentStash].
#' Storage of the object's MS data and sample information is handled by the
#' functions of the [MsExperimentStash::MsExperimentStash] with the *xcms*
#' preprocessing results being added to the stash.
#' Data from the object's slots are stored to respective folders (using
#' alabaster functionality). Refer to the documentation of the
#' [MsExperimentStash::MsExperimentStash] for information on the format of the
#' stored MS data and sample information. *xcms*-specific data/folders are:
#'
#' For `XcmsExperiment` objects:
#'
#' - *chrom_peaks*: the identified chromatographic peaks (`chromPeaks()`),
#'   stored as a numeric HDF5 array.
#' - *chrom_peak_data*: the data from the object's `chromPeakData()`, saved in
#'   HDF5 format.
#' - *feature_definitions*: the object's `featureDefinitions()`, saved in HDF5
#'   format.
#' - *xcms_experiment_process_history.json*: the object's `processHistory()`
#'   serialized in JSON format.
#'
#' For `XcmsExperimentHdf5` objects:
#'
#' - The HDF5 file with the preprocessing results is copied into the stash
#'   folder (same file name as the original HDF5 file).
#' - *hdf5_file* folder: contains the `character(1)` with the file name of the
#'   HDF5 file with the *xcms* preprocessing results.
#' - *hdf5_mod_count* folder: contains the content of the object's
#'   `@hdf5_mod_count` slot (an `integer(1)`).
#' - *sample_id* folder: contains the `character` vector with the IDs of the
#'   individual samples in the result object.
#' - *chrom_peaks_ms_level* folder: contains the `integer` vector with the MS
#'   level(s) in which chromatographic peak detection(s) was/were performed.
#' - *gap_peaks_ms_level* folder: contains the `integer` vector with the MS
#'   level(s) in which gap-filling was performed.
#' - *features_ms_level* folder: contains the `integer` vector with the MS
#'   levels for which features were defined.
#' - *xcms_experiment_process_history.json* file: the object's
#'   `processHistory()` serialized in JSON format.
#'
#' @section Text file-based format, `PlainTextParam`:
#'
#' `saveMsObject()`/`readMsObject()` with `PlainTextParam` allows to save and
#' read *xcms* result objects from a text file-based stash. All preprocessing
#' results are stored in separate tabulator delimited text files. Each of these
#' files has the row names (representing either the chromatographic peak IDs or
#' feature IDs) written as first column and the column names as first row. The
#' files grouped by preprocessing result are:
#'
#' For `XcmsExperiment` objects:
#'
#' - Chromatographic peak detection results are stored in
#'   *xcms_experiment_chrom_peaks.txt* (`chromPeaks()`) and
#'   *xcms_experiment_chrom_peak_data.txt* (`chromPeakData()`).
#' - Correspondence results: the definitions of the LC-MS features
#'   (`featureDefinitions()`) are stored to
#'   *xcms_experiment_feature_definitions.txt* (one row per feature) and the
#'   assignment between chromatographic peaks and features (the `$peakidx`
#'   column of `featureDefinitions()`) to
#'   *xcms_experiment_feature_peak_index.txt*, with one row for each mapping
#'   of a chromatographic peak to a feature. These files are not created (or
#'   present in the stash) if no correspondence analysis was performed.
#' - The processing history (`processHistory()`) is stored in JSON format to
#'   *xcms_experiment_process_history.json*.
#'
#' For `XcmsExperimentHdf5` objects: contents of the individual slots of the
#' object are saved using `writeLines()` to one text file per slot.
#'
#' - The HDF5 file with the preprocessing results is copied into the stash
#'   folder (same file name as the original HDF5 file).
#' - *xcms_experiment_hdf5_hdf5_file.txt* file: the name of the HDF5 file with
#'   the preprocessing results (content of the `@hdf5_file` slot of the object).
#' - *xcms_experiment_hdf5_hdf5_mod_count.txt* file: the `integer(1)` from the
#'   `@hdf5_mod_count` slot of the object.
#' - *xcms_experiment_hdf5_sample_id.txt* file: the IDs of the individual
#'   samples, saved one per line in the txt file.
#' - *xcms_experiment_hdf5_chrom_peaks_ms_level.txt* file: the MS level(s) in
#'   which chromatographic peak detection was performed (one per line).
#' - *xcms_experiment_hdf5_gap_peaks_ms_level.txt* file: the MS level(s) in
#'   which gap-filling was performed (one per line).
#' - *xcms_experiment_hdf5_featrures_ms_level.txt* file: the MS level(s) in
#'   which features were defined (one per line).
#' - *xcms_experiment_process_history.json* file: the object's
#'   `processHistory()` serialized in JSON format.
#'
#' @note
#'
#' Overwriting an existing *XcmsExperimentStash* is not allowed.
#'
#' @param object An `XcmsExperiment` or `XcmsExperimentHdf5` object.
#'
#' @param param The parameter object to select and configure the stash format.
#'     Either [MsStash::AlabasterParam] or [MsStash::PlainTextParam].
#'
#' @param path For `saveObject()`:
#'
#' @param x An `XcmsExperiment` or `XcmsExperimentHdf5` object.
#'
#' @param ... For `saveMsObject()`: optional arguments passed down to the
#'     `saveMsObject()` function to stash the `Spectra` object (if present),
#'     such as `consolidate`. For `readMsObject()`: optional arguments for the
#'     `readMsObject()` call to restore the `Spectra` object (such as
#'     `spectraPath`). See [SpectraStash::SpectraStash] for more information.
#'
#' @author Philippine Louail, Johannes Rainer
#'
#' @examples
#'
#' ## Load the example xcms result object
#' library(xcms)
#' library(Spectra)
#' library(MsExperiment)
#' xmse <- loadXcmsData()
#'
#' ## Define the path where to create the XcmsExperimentStash
#' d <- file.path(tempdir(), "xcms_stash")
#'
#' ## Save the XcmsExperiment to a stash in alabaster format; Note: with
#' ## `consolidate = TRUE` also the MS data files are **copied** into the
#' ## stash folder, creating a bigger, but portable and self-contained
#' ## archive
#' saveMsObject(xmse, AlabasterParam(d), consolidate = TRUE)
#'
#' ## Show the content of the stash folder
#' library(fs)
#' dir_tree(d)
#'
#' ## Read the MsExperiment from the stash (without xcms preprocessing results)
#' res <- readMsObject(MsExperiment(), AlabasterParam(d))
#' res
#'
#' ## Read the full xcms result object
#' res <- readMsObject(XcmsExperiment(), AlabasterParam(d))
#'
#' ## Show the first identified chromatographic peaks
#' chromPeaks(res) |> head()
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @rdname XcmsExperimentStash
#'
#' @importFrom xcms hasFeatures
setMethod("saveMsObject", signature(object = "XcmsExperiment",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              callNextMethod()
              ## Always writing chrom peaks and process history
              .txt_write_chrom_peaks(object, param@path)
              .write_process_history(object, param@path)
              if (hasFeatures(object))
                  .txt_write_features(object, param@path)
          })

#' @rdname XcmsExperimentStash
setMethod("readMsObject", signature(object = "XcmsExperiment",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              res <- as(callNextMethod(), "XcmsExperiment")
              .check_directory_content(
                  param@path, c("xcms_experiment_chrom_peaks.txt",
                                "xcms_experiment_process_history.json"))
              res <- .txt_load_chrom_peaks(res, param@path)
              res <- .load_process_history(res, param@path)
              if (file.exists(file.path(
                  param@path, "xcms_experiment_feature_definitions.txt")))
                  res <- .txt_load_features(res, param@path)
              validObject(res)
              res
          })

################################################################################
##    AlabasterParam
################################################################################

#' @rdname XcmsExperimentStash
#'
#' @importClassesFrom xcms XcmsExperiment
#'
#' @importFrom alabaster.base altSaveObject
#'
#' @importFrom alabaster.base saveObjectFile
#'
#' @importFrom alabaster.base readObjectFile
#'
#' @importMethodsFrom MsExperimentStash saveObject
#'
#' @importMethodsFrom alabaster.matrix saveObject
setMethod("saveObject", "XcmsExperiment", function(x, path, ...) {
    altSaveObject(as(x, "MsExperiment"), path, ...)
    altSaveObject(x@chromPeaks, file.path(path, "chrom_peaks"))
    altSaveObject(x@chromPeakData, file.path(path, "chrom_peak_data"))
    altSaveObject(x@featureDefinitions, file.path(path, "feature_definitions"))
    .write_process_history(x, path)
    info <- readObjectFile(path)
    info$contains <- "ms_experiment"
    saveObjectFile(path, "xcms_experiment", info)
})

validateAlabasterXcmsExperiment <- function(path = character(),
                                            metadata = list()) {
    .check_directory_content(
        path, c("chrom_peaks", "chrom_peak_data", "feature_definitions",
                "xcms_experiment_process_history.json"))
}

#' @importFrom alabaster.base altReadObject
#'
#' @importFrom methods validObject
readAlabasterXcmsExperiment <- function(path = character(), metadata = list(),
                                        ...) {
    validateAlabasterXcmsExperiment(path, metadata)
    metadata$type <- "ms_experiment"
    res <- altReadObject(path, metadata = metadata, ...)
    res <- as(res, "XcmsExperiment")
    res <- .load_process_history(res, path)
    res@chromPeaks <- as.matrix(altReadObject(file.path(path, "chrom_peaks")))
    res@chromPeakData <- as.data.frame(
        altReadObject(file.path(path, "chrom_peak_data")))
    res@featureDefinitions <- as.data.frame(altReadObject(
        file.path(path, "feature_definitions")))
    validObject(res)
    res
}

#' @importClassesFrom MsStash AlabasterParam
#'
#' @importMethodsFrom MsStash saveMsObject
#'
#' @rdname XcmsExperimentStash
setMethod("saveMsObject", signature(object = "XcmsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, param@path, ...)
          })

#' @importMethodsFrom MsStash readMsObject
#'
#' @rdname XcmsExperimentStash
setMethod("readMsObject", signature(object = "XcmsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterXcmsExperiment(param@path, ...)
          })
