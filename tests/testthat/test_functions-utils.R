test_that(".check_directory_content works", {
    expect_error(.check_directory_content(tempdir(), "my_file"), "not found")
    file.create(file.path(tempdir(), "my_file"))
    expect_no_error(.check_directory_content(tempdir(), "my_file"))
    unlink(file.path(tempdir(), "my_file"))
})

## test_that(".check_overwriting works", {
##     expect_error(.check_overwriting(tempdir()), "contains already")
##     expect_no_error(.check_overwriting(file.path(tempdir(), "a")))
## })

test_that(".load_process_history works", {
    pth <- tempdir()
    expect_error(.load_process_history(xmse, pth), "process_history.json")
})

test_that(".txt_write_chrom_peaks and .txt_read_chrom_peaks works", {
    d <- file.path(tempdir(), "xcms_test")
    dir.create(d)

    expect_no_error(.txt_write_chrom_peaks(xmse, d))
    expect_true(all(c("xcms_experiment_chrom_peaks.txt",
                      "xcms_experiment_chrom_peak_data.txt") %in% dir(d)))
    res <- .txt_load_chrom_peaks(XcmsExperiment(), d)
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(res@chromPeaks, xmse@chromPeaks)
    expect_equal(res@chromPeakData, xmse@chromPeakData)

    unlink(file.path(d, "xcms_experiment_chrom_peak_data.txt"))
    expect_error(.txt_load_chrom_peaks(XcmsExperiment(), d),
                 "chrom_peak_data.txt")
    unlink(file.path(d, "xcms_experiment_chrom_peaks.txt"))
    expect_error(.txt_load_chrom_peaks(XcmsExperiment(), d),
                 "chrom_peaks.txt")

    unlink(d, recursive = TRUE)
})

test_that(".txt_write_features and .txt_load_features works", {
    d <- file.path(tempdir(), "xcms_test")
    dir.create(d)

    expect_no_error(.txt_write_features(xmse, d))
    expect_true(all(c("xcms_experiment_feature_definitions.txt",
                      "xcms_experiment_feature_peak_index.txt") %in% dir(d)))
    res <- .txt_load_features(XcmsExperiment(), d)
    expect_s4_class(res, "XcmsExperiment")
    expect_equal(res@featureDefinitions, xmse@featureDefinitions)

    unlink(file.path(d, "xcms_experiment_feature_peak_index.txt"))
    expect_error(.txt_load_features(XcmsExperiment(), d),
                 "feature_peak_index.txt")
    unlink(file.path(d, "xcms_experiment_feature_definitions.txt"))
    expect_error(.txt_load_features(XcmsExperiment(), d),
                 "feature_definitions.txt")

    unlink(d, recursive = TRUE)
})

test_that(".txt_load_chrom_peaks works", {
    pth <- tempdir()
    expect_error(.txt_load_chrom_peaks(xcmse, pth), "chrom_peaks.txt")
    write.table(chromPeaks(xmse),
                file = file.path(pth, "xcms_experiment_chrom_peaks.txt"),
                sep = "\t")
    expect_error(.txt_load_chrom_peaks(xmse, pth),
                 "chrom_peak_data.txt")
    file.remove(file.path(pth, "xcms_experiment_chrom_peaks.txt"))
})

test_that(".txt_load_features works", {
    pth <- tempdir()
    write.table(
        featureDefinitions(xmse)[, 1:8],
        file = file.path(pth, "xcms_experiment_feature_definitions.txt"),
        sep = "\t")
    expect_error(.txt_load_features(xmse, pth), "feature_peak_index.txt")
})
