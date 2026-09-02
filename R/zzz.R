#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @importFrom alabaster.base registerReadObjectFunction
.onLoad <- function(libname, pkgname) {
    ## XcmsExperiment
    registerValidateObjectFunction(
        "xcms_experiment", validateAlabasterXcmsExperiment)
    registerReadObjectFunction(
        "xcms_experiment", readAlabasterXcmsExperiment)
    ## XcmsExperimentHdf5
    registerValidateObjectFunction(
        "xcms_experiment_hdf5", validateAlabasterXcmsExperimentHdf5)
    registerReadObjectFunction(
        "xcms_experiment_hdf5", readAlabasterXcmsExperimentHdf5)
}
