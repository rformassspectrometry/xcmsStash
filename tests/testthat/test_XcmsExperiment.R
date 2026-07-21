library(xcms)
library(Spectra)
library(SpectraStash)
library(MsExperiment)
library(alabaster.base)
xmse <- loadXcmsData()
## Fix
xmse@processHistory <- lapply(xmse@processHistory, function(z) {
    z@param <- updateObject(z@param)
    z
})
xmseg_filt <- filterMzRange(xmse, c(200, 500))
xmseg_filt <- filterRt(xmseg_filt, c(3000, 4000))

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
})
