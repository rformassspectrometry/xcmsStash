test_that("saveObject,XcmsExperiment works", {
    d <- file.path(tempdir(), "xmse_stash")

    ## Empty object
    expect_no_error(saveObject(XcmsExperiment(), d))
    expect_true(all(c("chrom_peaks", "chrom_peak_data", "feature_definitions",
                      "metadata", "OBJECT", "other_data", "sample_data",
                      "sample_data_links", "sample_data_links_mcols",
                      "xcms_experiment_process_history.json") %in% dir(d)))
    res <- readObject(d)
    expect_equal(res, XcmsExperiment())
    expect_error(saveObject(xmse, d), "existing")
    unlink(d, recursive = TRUE)

    expect_no_error(saveObject(xmse, d))
    expect_true(all(c("chrom_peaks", "chrom_peak_data", "feature_definitions",
                      "metadata", "OBJECT", "other_data", "sample_data",
                      "sample_data_links", "sample_data_links_mcols",
                      "xcms_experiment_process_history.json") %in% dir(d)))
    cpks <- readObject(file.path(d, "chrom_peaks"))
    expect_s4_class(cpks, "DelayedMatrix")
    expect_equal(as.matrix(cpks), chromPeaks(xmse))
    cpkd <- readObject(file.path(d, "chrom_peak_data"))
    expect_equal(chromPeakData(xmse), cpkd)
    fd <- readObject(file.path(d, "feature_definitions"))
    expect_equal(as.data.frame(fd), featureDefinitions(xmse))

    ## Can we load the object as MsExperiment?
    res <- readObject(d, metadata = list(type = "ms_experiment"))
    expect_s4_class(res, "MsExperiment")

    res <- readObject(d)
    expect_equal(xmse@processHistory[[1]], res@processHistory[[1]])
    expect_equal(xmse@processHistory[[2]], res@processHistory[[2]])
    expect_equal(xmse@chromPeaks, res@chromPeaks)
    expect_equal(xmse@featureDefinitions, res@featureDefinitions)
    unlink(d, recursive = TRUE)
})

test_that("saveMsObject,readMsObject,XcmsExperiment,AlabasterParam", {
    d <- file.path(tempdir(), "xmse_stash")

    expect_no_error(saveMsObject(xmseg_filt, AlabasterParam(d),
                                 consolidate = TRUE))
    s <- readMsObject(Spectra(), AlabasterParam(file.path(d, "spectra")))
    expect_equal(normalizePath(dataStorageBasePath(s)),
                 normalizePath(file.path(d, "spectra", "backend")))

    res <- readMsObject(XcmsExperiment(), AlabasterParam(d))
    expect_equal(chromPeaks(res), chromPeaks(xmseg_filt))
    expect_equal(chromPeakData(res), chromPeakData(xmseg_filt))
    expect_equal(featureDefinitions(res), featureDefinitions(xmseg_filt))
    expect_equal(rtime(res), rtime(xmseg_filt))

    ## Read as MsExperiment
    mse <- readMsObject(MsExperiment(), AlabasterParam(d))
    expect_s4_class(mse, "MsExperiment")

    unlink(d, recursive = TRUE)

    ## No features
    ref <- dropFeatureDefinitions(xmseg_filt)
    expect_no_error(saveMsObject(ref, AlabasterParam(d)))
    res <- readMsObject(XcmsExperiment(), AlabasterParam(d))
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(hasChromPeaks(res), hasChromPeaks(ref))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(ref))
    expect_equal(hasFeatures(res), hasFeatures(ref))
    expect_equal(length(processHistory(res)), length(processHistory(ref)))
    unlink(d, recursive = TRUE)

    ## No chrom peaks
    ref <- dropChromPeaks(ref)
    expect_no_error(saveMsObject(ref, AlabasterParam(d)))
    res <- readMsObject(XcmsExperiment(), AlabasterParam(d))
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(hasChromPeaks(res), hasChromPeaks(ref))
    expect_equal(length(processHistory(res)), length(processHistory(ref)))
    expect_equal(chromPeaks(res), chromPeaks(ref))
    unlink(d, recursive = TRUE)
})

test_that("saveMsObject,readMsObject,XcmsExperiment,PlainTextParam work", {
    d <- file.path(tempdir(), "xmse_txt_stash")

    expect_no_error(saveMsObject(xmseg_filt, PlainTextParam(d)))
    expect_true(all(c("xcms_experiment_chrom_peaks.txt",
                      "xcms_experiment_chrom_peak_data.txt",
                      "xcms_experiment_feature_definitions.txt",
                      "xcms_experiment_feature_peak_index.txt",
                      "xcms_experiment_process_history.json") %in% dir(d)))
    res <- readMsObject(XcmsExperiment(), PlainTextParam(d))
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(hasChromPeaks(res), hasChromPeaks(xmseg_filt))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(xmseg_filt))
    expect_equal(hasFeatures(res), hasFeatures(xmseg_filt))
    expect_equal(length(processHistory(res)),
                 length(processHistory(xmseg_filt)))
    expect_equal(rtime(res), rtime(xmseg_filt))
    expect_equal(chromPeaks(res), chromPeaks(xmseg_filt))
    expect_equal(featureDefinitions(res), featureDefinitions(xmseg_filt))
    unlink(d, recursive = TRUE)

    ## No features
    ref <- dropFeatureDefinitions(xmseg_filt)
    expect_no_error(saveMsObject(ref, PlainTextParam(d)))
    res <- readMsObject(XcmsExperiment(), PlainTextParam(d))
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(hasChromPeaks(res), hasChromPeaks(ref))
    expect_equal(hasAdjustedRtime(res), hasAdjustedRtime(ref))
    expect_equal(hasFeatures(res), hasFeatures(ref))
    expect_equal(length(processHistory(res)), length(processHistory(ref)))
    expect_equal(chromPeaks(res), chromPeaks(ref))
    expect_equal(featureDefinitions(res), featureDefinitions(ref))
    unlink(d, recursive = TRUE)

    ## No chrom peaks
    ref <- dropChromPeaks(ref)
    expect_no_error(saveMsObject(ref, PlainTextParam(d)))
    res <- readMsObject(XcmsExperiment(), PlainTextParam(d))
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(hasChromPeaks(res), hasChromPeaks(ref))
    expect_equal(length(processHistory(res)), length(processHistory(ref)))
    unlink(d, recursive = TRUE)

    ## Passing of consolidate = TRUE
    expect_no_error(saveMsObject(xmseg_filt, PlainTextParam(d),
                                 consolidate = TRUE))
    expect_true(all(c("KO", "WT") %in% dir(d)))
    res <- readMsObject(XcmsExperiment(), PlainTextParam(d))
    expect_equal(mz(spectra(res)), mz(spectra(xmseg_filt)))
    unlink(d, recursive = TRUE)
})
