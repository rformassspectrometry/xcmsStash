library(testthat)
library(xcmsStash)
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

test_check("xcmsStash")
