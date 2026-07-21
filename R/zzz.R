#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @importFrom alabaster.base registerReadObjectFunction
.onLoad <- function(libname, pkgname) {
    ## XcmsExperiment
    registerValidateObjectFunction(
        "xcms_experiment", validateAlabasterXcmsExperiment)
    registerReadObjectFunction("xcms_experiment", readAlabasterXcmsExperiment)
}
