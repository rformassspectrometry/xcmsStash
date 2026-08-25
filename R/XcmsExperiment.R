#' @title `XcmsExperiment` Stash
#'
#' @name XcmsExperimentStash
#'
#' @description
#'
#' `XcmsExperiment` *xcms* result objects can be stored to (or read from)
#' *XcmsExperimentStash*es using the `saveMsObject()` and `readMsObject()`
#' functions which take a second argument `parameter` to select and configure
#' the format of the stash. The XcmsExperimentStash extends the
#' [MsExperimentStash::MsExperimentStash] defined in the *MsExperimentStash*
#' package, i.e., it shares the same content, but adds the *xcms* preprocessing
#' results to it.
#'
#' The supported stash formats are listed in the sections below.
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' This alabster stash format is the most complete and reliable way for
#' long-term (and portable) storage of an `XcmsExperiment`. Objects can be
#' saved or read from this stash format either using the `saveMsObject()`
#' and `readMsObject()` functions together with an `AlabasterParam` object
#' or also using the [alabaster.base::saveObject()] and
#' [alabaster.base::readObject()] functions from the *alabaster.base* package.
#' The alabaster stash format for `XcmsExperiment` extends the
#' [MsExperimentStash::MsExperimentStash]. Storage of the object's MS data and
#' sample information is handled by the functions of the
#' [MsExperimentStash::MsExperimentStash] with the *xcms* preprocessing results
#' being added to the stash.
#' Data from the object's slots are stored to respective folders (using
#' alabaster functionality). Refer to the documentation of the
#' [MsExperimentStash::MsExperimentStash] for information on the format of the
#' stored MS data and sample information. *xcms*-specific data/folders are:
#'
#' - *chrom_peaks*: the identified chromatographic peaks (`chromPeaks()`),
#'   stored as a numeric HDF5 array.
#' - *chrom_peak_data*: the data from the object's `chromPeakData()`, saved in
#'   HDF5 format.
#' - *feature_definitions*: the object's `featureDefinitions()`, saved in HDF5
#'   format.
#' - *xcms_experiment_process_history.json*: the object's `processHistory()`
#'   serialized as a JSON object.
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
#' @note
#'
#' Overwriting an existing *XcmsExperimentStash* is not allowed.
#'
#' @param object A `XcmsExperiment` object.
#'
#' @param param The parameter object to select and configure the stash format.
#'     Either [MsStash::AlabasterParam] or [MsStash::PlainTextParam].
#'
#' @param path For `saveObject()`:
#'
#' @param x A `XcmsExperiment` object.
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
#' ## Ensure all parameter objects in the object's process history are in
#' ## the latest format.
#' xmse@processHistory <- lapply(xmse@processHistory, function(z) {
#'     z@param <- updateObject(z@param)
#'     z
#' })
#'
#' ## Define the path where to create the XcmsExperimentStash
#' d <- file.path(tempdir(), "xcms_stash")
#'
#' ## Save the XcmsExperiment to a stash in alabaster format; Note: with
#' ## `consolidate = TRUE` the MS data files are also **copied** into the
#' ## stash
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
