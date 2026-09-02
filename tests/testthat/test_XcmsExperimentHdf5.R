
test_that("txt format for XcmsExperimentHdf5 works", {
    a <- toXcmsExperimentHdf5(xmse)
    d <- file.path(tempdir(), "txt_test")

    ## Full results
    expect_no_error(saveMsObject(a, PlainTextParam(d)))
    req_files <- c("xcms_experiment_hdf5_hdf5_file.txt",
                   "xcms_experiment_hdf5_hdf5_mod_count.txt",
                   "xcms_experiment_hdf5_sample_id.txt",
                   "xcms_experiment_hdf5_chrom_peaks_ms_level.txt",
                   "xcms_experiment_hdf5_gap_peaks_ms_level.txt",
                   "xcms_experiment_hdf5_features_ms_level.txt")
    expect_true(all(req_files %in% dir(d)))
    res <- readMsObject(MsExperiment(), PlainTextParam(d))
    expect_equal(sampleData(a), sampleData(res))
    expect_equal(spectra(a)$rtime, spectra(res)$rtime)
    res <- readMsObject(XcmsExperimentHdf5(), PlainTextParam(d))
    expect_s4_class(res, "XcmsExperimentHdf5")
    expect_equal(sampleData(res), sampleData(a))
    expect_equal(spectra(res)$mz, spectra(a)$mz)
    expect_equal(spectra(res)$rtime, spectra(a)$rtime)
    expect_equal(chromPeaks(res), chromPeaks(a))
    expect_equal(chromPeakData(res), chromPeakData(a))
    expect_equal(featureDefinitions(res), featureDefinitions(a))
    expect_equal(res@sample_id, a@sample_id)
    expect_equal(res@hdf5_mod_count, a@hdf5_mod_count)
    expect_equal(basename(res@hdf5_file), basename(a@hdf5_file))
    expect_equal(res@hdf5_file, file.path(d, basename(a@hdf5_file)))
    expect_equal(res@chrom_peaks_ms_level, a@chrom_peaks_ms_level)
    expect_equal(res@gap_peaks_ms_level, a@gap_peaks_ms_level)
    expect_equal(res@features_ms_level, a@features_ms_level)
    unlink(d, recursive = TRUE)

    ## Only chrom peaks.
    a <- dropFeatureDefinitions(a)
    expect_false(hasFeatures(a))
    expect_no_error(saveMsObject(a, PlainTextParam(d)))
    req_files <- c("xcms_experiment_hdf5_hdf5_file.txt",
                   "xcms_experiment_hdf5_hdf5_mod_count.txt",
                   "xcms_experiment_hdf5_sample_id.txt",
                   "xcms_experiment_hdf5_chrom_peaks_ms_level.txt",
                   "xcms_experiment_hdf5_gap_peaks_ms_level.txt",
                   "xcms_experiment_hdf5_features_ms_level.txt")
    expect_true(all(req_files %in% dir(d)))
    res <- readMsObject(XcmsExperimentHdf5(), PlainTextParam(d))
    expect_s4_class(res, "XcmsExperimentHdf5")
    expect_equal(res@hdf5_mod_count, a@hdf5_mod_count)
    expect_equal(res@sample_id, a@sample_id)
    expect_equal(res@chrom_peaks_ms_level, a@chrom_peaks_ms_level)
    expect_equal(res@gap_peaks_ms_level, a@gap_peaks_ms_level)
    expect_equal(res@features_ms_level, a@features_ms_level)
    expect_equal(chromPeaks(res), chromPeaks(a))
    expect_equal(length(a@processHistory), length(res@processHistory))
    unlink(d, recursive = TRUE)

    ## With consolidate = TRUE
    expect_no_error(saveMsObject(a, PlainTextParam(d), consolidate = TRUE))
    expect_true(all(c("KO", "WT") %in% dir(d)))
    res <- readMsObject(XcmsExperimentHdf5(), PlainTextParam(d))
    expect_equal(dirname(res@hdf5_file), d)
    expect_equal(dataStorageBasePath(spectra(res)), normalizePath(d))
    expect_equal(spectra(res)$rtime, spectra(a)$rtime)
    expect_equal(chromPeaks(res), chromPeaks(a))
    unlink(d, recursive = TRUE)
})

test_that("alabaster format for XcmsExperimentHdf5 works", {
    a <- toXcmsExperimentHdf5(xmse)
    d <- file.path(tempdir(), "h5_test")

    expect_no_error(saveObject(a, d))
    expect_error(saveMsObject(a, AlabasterParam(d)), "existing path")
    expect_true(all(c("hdf5_file", "hdf5_mod_count", "sample_id",
                      "chrom_peaks_ms_level", "gap_peaks_ms_level",
                      "features_ms_level", basename(a@hdf5_file)) %in% dir(d)))
    res <- readMsObject(new("XcmsExperimentHdf5"), AlabasterParam(d))
    expect_s4_class(res, "XcmsExperimentHdf5")
    expect_equal(hasFeatures(res), hasFeatures(a))
    expect_equal(hasChromPeaks(res), hasChromPeaks(a))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(a))
    expect_equal(chromPeaks(res), chromPeaks(a))
    expect_equal(featureDefinitions(res), featureDefinitions(a))
    expect_equal(res@hdf5_file, file.path(d, basename(a@hdf5_file)))
    expect_equal(length(processHistory(res)), length(processHistory(a)))
    unlink(d, recursive = TRUE)

    ## Without features
    b <- dropFeatureDefinitions(a)
    expect_no_error(saveObject(b, d))
    expect_error(saveMsObject(b, AlabasterParam(d)), "existing path")
    expect_true(all(c("hdf5_file", "hdf5_mod_count", "sample_id",
                      "chrom_peaks_ms_level", "gap_peaks_ms_level",
                      "features_ms_level", basename(b@hdf5_file)) %in% dir(d)))
    res <- readMsObject(new("XcmsExperimentHdf5"), AlabasterParam(d))
    expect_s4_class(res, "XcmsExperimentHdf5")
    expect_equal(hasFeatures(res), hasFeatures(b))
    expect_equal(hasChromPeaks(res), hasChromPeaks(b))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(b))
    expect_equal(chromPeaks(res), chromPeaks(b))
    expect_equal(nrow(featureDefinitions(res)), nrow(featureDefinitions(b)))
    expect_equal(res@hdf5_file, file.path(d, basename(b@hdf5_file)))
    expect_equal(length(processHistory(res)), length(processHistory(b)))
    unlink(d, recursive = TRUE)

    ## Without chrom peaks
    b <- dropChromPeaks(b)
    expect_no_error(saveObject(b, d))
    expect_error(saveMsObject(b, AlabasterParam(d)), "existing path")
    expect_true(all(c("hdf5_file", "hdf5_mod_count", "sample_id",
                      "chrom_peaks_ms_level", "gap_peaks_ms_level",
                      "features_ms_level", basename(b@hdf5_file)) %in% dir(d)))
    res <- readMsObject(new("XcmsExperimentHdf5"), AlabasterParam(d))
    expect_s4_class(res, "XcmsExperimentHdf5")
    expect_equal(hasFeatures(res), hasFeatures(b))
    expect_equal(hasChromPeaks(res), hasChromPeaks(b))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(b))
    expect_equal(nrow(chromPeaks(res)), nrow(chromPeaks(b)))
    expect_equal(nrow(featureDefinitions(res)), nrow(featureDefinitions(b)))
    expect_equal(res@hdf5_file, file.path(d, basename(b@hdf5_file)))
    expect_equal(length(processHistory(res)), length(processHistory(b)))
    unlink(d, recursive = TRUE)
})
