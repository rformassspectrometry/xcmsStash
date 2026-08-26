# Safely Store xcms Result Objects in a Portable Stash

## Introduction

Data objects in R can be serialized to disk in R’s *rds* or *RData*
format using the base R [`save()`](https://rdrr.io/r/base/save.html)
function and re-imported using the
[`load()`](https://rdrr.io/r/base/load.html) function. This binary file
format can however not be used easily in other programming languages.
The *[MsStash](https://bioconductor.org/packages/3.23/MsStash)* package
defines a basic framework to store and import mass spectrometry (MS)
data objects in various storage formats aiming to simplify and
facilitate data exchange between software. The *xcmsStash* package
implements portable data storage formats (stashes) for result objects
from Bioconductor’s
*[xcms](https://bioconductor.org/packages/3.23/xcms)* package. Supported
stash formats are, next to storage in simple plain text files, also
Bioconductor’s *alabaster* format defined in the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
and related packages.

## Installation

The package can be installed with the *BiocManager* package. To install
*BiocManager* use `install.packages("BiocManager")` and, after that,
`BiocManager::install("xcmsStash")` to install this package along with
all required dependencies.

## A stash for *xcms* result objects

*xcms* result objects can be saved and restored through the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
and
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
functions into (or from) MS data stashes. At present, `XcmsExperiment`
objects can be saved in the following stash formats:

- *Alabaster*-based format: storage of MS data and *xcms* results using
  Bioconductor’s
  *[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
  framework saving files in HDF5 and JSON format. This stash format can
  be selected and configured by passing an `AlabasterParam` to the
  [`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  or
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  function. *alabaster*-based stashes also fully support the
  [`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
  and
  [`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
  functions from *alabaster.base*.
- Text file-based format: storage of the MS data and preprocessing
  results in plain text files. This stash format can be selected and
  configured by passing a `PlainTextParam` to the
  [`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  and
  [`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
  function.

See also the vignette from the
*[MsStash](https://bioconductor.org/packages/3.23/MsStash)* package for
details on the formats and the documentation and vignettes of the
related
*[SpectraStash](https://bioconductor.org/packages/3.23/SpectraStash)*
and
*[MsExperimentStash](https://bioconductor.org/packages/3.23/MsExperimentStash)*
packages for information on storage of the result object’s MS data.

Below we load an example `XcmsExperiment` result object provided by the
*xcms* package.

[`library`](https://rdrr.io/r/base/library.html)`(`[`xcms`](https://github.com/sneumann/xcms)`)`

    ## Warning: replacing previous import 'MsCoreUtils::group' by
    ## 'BiocGenerics::group' when loading 'xcms'

[`library`](https://rdrr.io/r/base/library.html)`(`[`MsExperiment`](https://github.com/RforMassSpectrometry/MsExperiment)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`xcmsStash`](https://github.com/RforMassSpectrometry/xcmsStash)`)`` `` ``xmse`` ``<-`` `[`loadXcmsData`](https://rdrr.io/pkg/xcms/man/loadXcmsData.html)`(``"xmse"``)`` ``xmse`

    ## Object of class XcmsExperiment 
    ##  Spectra: MS1 (8688) 
    ##  Experiment data: 8 sample(s)
    ##  Sample data links:
    ##   - spectra: 8 sample(s) to 8688 element(s).
    ##  xcms results:
    ##   - chromatographic peaks: 3651 in MS level(s): 1 
    ##   - adjusted retention times
    ##   - correspondence results: 351 features in MS level(s): 1

The `XcmsExperiment` thus contains the full results from a *xcms*-based
LC-MS data preprocessing, chromatographic peaks, adjusted retention
times and LC-MS features. We next store this object to a *xcmsStash*
using the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function with an `AlabasterParam` parameter object to choose and
configure the *alabaster*-based stash format. The location of the stash
can be set with the `path` argument of this parameter object. For the
present example we save the stash to a temporary folder.

`#' Define the location of the stash`` ``d`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"xmse_stash"``)`` `` ``#' Configure the format and location`` ``ap`` ``<-`` `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)`` `` ``` #' Save the `XcmsExperiment` object to the stash ``` `[`saveMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(``xmse``, ``ap``)`

[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
was storing, next to the results present in the `XcmsExperiment` object
also all other experiment-related information from the MS data
containers `MsExperiment` and `Spectra`, that the object contains. The
content of the thus created stash folder is:

[`library`](https://rdrr.io/r/base/library.html)`(`[`fs`](https://fs.r-lib.org)`)`` `[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(``d``)`

    ## /tmp/RtmpTIRc4k/file1f96639fc444/xmse_stash
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── chrom_peak_data
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── chrom_peaks
    ## │   ├── OBJECT
    ## │   └── array.h5
    ## ├── experiment_files
    ## │   ├── OBJECT
    ## │   └── x
    ## │       ├── OBJECT
    ## │       └── list_contents.json.gz
    ## ├── feature_definitions
    ## │   ├── OBJECT
    ## │   ├── basic_columns.h5
    ## │   └── other_columns
    ## │       └── 9
    ## │           ├── OBJECT
    ## │           └── list_contents.json.gz
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── other_data
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── sample_data
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── sample_data_links
    ## │   ├── OBJECT
    ## │   ├── list_contents.json.gz
    ## │   └── other_contents
    ## │       └── 0
    ## │           ├── OBJECT
    ## │           └── array.h5
    ## ├── sample_data_links_mcols
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── spectra
    ## │   ├── OBJECT
    ## │   ├── backend
    ## │   │   ├── OBJECT
    ## │   │   └── spectra_data
    ## │   │       ├── OBJECT
    ## │   │       └── basic_columns.h5
    ## │   ├── metadata
    ## │   │   ├── OBJECT
    ## │   │   └── list_contents.json.gz
    ## │   ├── processing
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   ├── processing_chunk_size
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   ├── processing_queue_variables
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   └── spectra_processing_queue.json
    ## └── xcms_experiment_process_history.json

An `XcmsExperiment` contains, next to the results from the *xcms*
preprocessing, also the MS data of the experiment along with the
experiment’s sample information. All the experiment-relevant information
is contained in a `MsExperiment` object (which the `XcmsExperiment`
extends), with the actual MS data of the experiment being represented by
a `Spectra` object. Calling
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html) on
a `XcmsExperiment` triggers the serialization mechanism of all these
contained or extended MS data objects. In alabaster format each slot of
an object is then stored to a sub-directory within the main *xcmsStash*
directory. Folders *chrom_peak_data*, *chrom_peaks*,
*feature_definitions* in the stash folder above contain the *xcms*
preprocessing results, and the *xcms_experiment_process_history.json*
file provides the full data processing history (all parameter objects
from the object’s
[`processHistory()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
serialized in JSON format). All other folders contain the remaining MS
experiment-relevant information in their respective *sub-stashes*. The
*spectra* folder contains for example the experiment’s MS data as a
*SpectraStash* (defined in the
*[SpectraStash](https://bioconductor.org/packages/3.23/SpectraStash)*
package).

An `XcmsExperiment` can be restored from an *xcmsStash* with the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function along with the parameter object specifying the format of the
stash. To load the result object from the alabaster-format stash created
above we use the
[`AlabasterParam()`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
parameter object providing the file path to the stash as argument. In
addition we need to define the expected result (return) object with the
first parameter to
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
(in our case an
[`XcmsExperiment()`](https://rdrr.io/pkg/xcms/man/XcmsExperiment.html)
object).

`#' Restore the result object`` ``res`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`XcmsExperiment`](https://rdrr.io/pkg/xcms/man/XcmsExperiment.html)`(``)``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)``)`` ``res`

    ## Object of class XcmsExperiment 
    ##  Spectra: MS1 (8688) 
    ##  Experiment data: 8 sample(s)
    ##  Sample data links:
    ##   - spectra: 8 sample(s) to 8688 element(s).
    ##  xcms results:
    ##   - chromatographic peaks: 3651 in MS level(s): 1 
    ##   - adjusted retention times
    ##   - correspondence results: 351 features in MS level(s): 1

As mentioned above, *xcmsStash* folders are organized in a modular way
with the different components being stored in sub-folders
(*sub-stashes*). This allows to load only selected parts from the object
instead of the full object. We can for example read only the MS
experiment information from the stash, omitting the *xcms* preprocessing
results.

`#' Load the MS experiment data from the stash`` ``mse`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`MsExperiment`](https://rdrr.io/pkg/MsExperiment/man/MsExperiment.html)`(``)``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d``)``)`` ``mse`

    ## Object of class MsExperiment 
    ##  Spectra: MS1 (8688) 
    ##  Experiment data: 8 sample(s)
    ##  Sample data links:
    ##   - spectra: 8 sample(s) to 8688 element(s).

Or even just the `Spectra` object representing the MS data of the
experiment from the *spectra* sub-folder of the stash directory:

`#' Load the Spectra object from the stash`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`Spectra`](https://github.com/RforMassSpectrometry/Spectra)`)`` ``sps`` ``<-`` `[`readMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(`[`Spectra`](https://rdrr.io/pkg/Spectra/man/Spectra.html)`(``)``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d``, ``"spectra"``)``)``)`` ``sps`

    ## MSn data (Spectra) with 8688 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1   2551.46        33
    ## 2            1   2553.02        34
    ## 3            1   2554.59        35
    ## 4            1   2556.15        36
    ## 5            1   2557.72        37
    ## ...        ...       ...       ...
    ## 8684         1   4243.17      1114
    ## 8685         1   4244.74      1115
    ## 8686         1   4246.30      1116
    ## 8687         1   4247.87      1117
    ## 8688         1   4249.43      1118
    ##  ... 31 more variables/columns.
    ## 
    ## file(s):
    ## ko15.CDF
    ## ko16.CDF
    ## ko21.CDF
    ##  ... 5 more files
    ## Processing:
    ##  Filter: select retention time [2550..4250] on MS level(s)  [Wed Mar 12 08:35:51 2025]

Depending on the data backend the `Spectra` object of an
`XcmsExperiment` uses, only references to the actual MS data might be
stored within the *xcmsStash*. As shown by the print output above, the
loaded `Spectra` object uses a `MsBackendMzR` backend to represent the
MS data. This type of backend only loads general metadata information
into memory and reads the actual MS data only on-demand from the
original MS data files. We can use the
[`dataStorageBasePath()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
function to get the location of these original MS data files for this
`Spectra` object.

`#' Get the location of the original MS data files`` `[`dataStorageBasePath`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)`(``sps``)`

    ## [1] "/__w/_temp/Library/faahKO/cdf"

The MS data files are thus only referenced from the `Spectra` object but
not part of the stash folder. If the original data files are moved to
another location or if the *xcmsStash* folder is moved to a different
computer, the location of these MS data files needs to be provided with
the `spectraPath` parameter of the
[`readMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
function to allow restoring the object from the stash (see documentation
and vignette of the
*[SpectraStash](https://bioconductor.org/packages/3.23/SpectraStash)*
package for more information).

Alternatively, it is possible to store also the MS data files **into**
the stash folder by passing `consolidate = TRUE` to the
[`saveMsObject()`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)
call:

`#' Store the result object consolidating the full data into the stash`` ``d2`` ``<-`` `[`file.path`](https://rdrr.io/r/base/file.path.html)`(`[`tempdir`](https://rdrr.io/r/base/tempfile.html)`(``)``, ``"consolidated_xcms_stash"``)`` `[`saveMsObject`](https://rdrr.io/pkg/MsStash/man/saveMsObject.html)`(``xmse``, `[`AlabasterParam`](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)`(``d2``)``, consolidate ``=`` ``TRUE``)`

Now the stash directory contains also the original MS data files, in
that particular example stored within sub-folders *KO* and *WT* within
the *spectra* sub-folder:

`#' List the directory content of the consolidated *xcmsStash*`` `[`dir_tree`](https://fs.r-lib.org/reference/dir_tree.html)`(``d2``)`

    ## /tmp/RtmpTIRc4k/consolidated_xcms_stash
    ## ├── OBJECT
    ## ├── _environment.json
    ## ├── chrom_peak_data
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── chrom_peaks
    ## │   ├── OBJECT
    ## │   └── array.h5
    ## ├── experiment_files
    ## │   ├── OBJECT
    ## │   └── x
    ## │       ├── OBJECT
    ## │       └── list_contents.json.gz
    ## ├── feature_definitions
    ## │   ├── OBJECT
    ## │   ├── basic_columns.h5
    ## │   └── other_columns
    ## │       └── 9
    ## │           ├── OBJECT
    ## │           └── list_contents.json.gz
    ## ├── metadata
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── other_data
    ## │   ├── OBJECT
    ## │   └── list_contents.json.gz
    ## ├── sample_data
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── sample_data_links
    ## │   ├── OBJECT
    ## │   ├── list_contents.json.gz
    ## │   └── other_contents
    ## │       └── 0
    ## │           ├── OBJECT
    ## │           └── array.h5
    ## ├── sample_data_links_mcols
    ## │   ├── OBJECT
    ## │   └── basic_columns.h5
    ## ├── spectra
    ## │   ├── OBJECT
    ## │   ├── backend
    ## │   │   ├── KO
    ## │   │   │   ├── ko15.CDF
    ## │   │   │   ├── ko16.CDF
    ## │   │   │   ├── ko21.CDF
    ## │   │   │   └── ko22.CDF
    ## │   │   ├── OBJECT
    ## │   │   ├── WT
    ## │   │   │   ├── wt15.CDF
    ## │   │   │   ├── wt16.CDF
    ## │   │   │   ├── wt21.CDF
    ## │   │   │   └── wt22.CDF
    ## │   │   └── spectra_data
    ## │   │       ├── OBJECT
    ## │   │       └── basic_columns.h5
    ## │   ├── metadata
    ## │   │   ├── OBJECT
    ## │   │   └── list_contents.json.gz
    ## │   ├── processing
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   ├── processing_chunk_size
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   ├── processing_queue_variables
    ## │   │   ├── OBJECT
    ## │   │   └── contents.h5
    ## │   └── spectra_processing_queue.json
    ## └── xcms_experiment_process_history.json

While this allows generating self-contained portable stashes, their file
size will be much larger, depending on the number and size of the
original MS data files.

Finally, the *xcmsStash* package implements also the
[`saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
and
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
methods from the
*[alabaster.base](https://bioconductor.org/packages/3.23/alabaster.base)*
package. Thus, the full stash, or also selected parts of a result object
can be read using these functions. Loading below for example the
`Spectra` object of the *xcms* result object using *alabaster*’s
[`readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
function:

`` #' Read the `Spectra` object from the *xcmsStash* ``` `[`library`](https://rdrr.io/r/base/library.html)`(`[`alabaster.base`](https://github.com/ArtifactDB/alabaster.base)`)`` ``sps`` ``<-`` `[`readObject`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)`(`[`file.path`](https://rdrr.io/r/base/file.path.html)`(``d2``, ``"spectra"``)``)`` ``sps`

    ## MSn data (Spectra) with 8688 spectra in a MsBackendMzR backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1   2551.46        33
    ## 2            1   2553.02        34
    ## 3            1   2554.59        35
    ## 4            1   2556.15        36
    ## 5            1   2557.72        37
    ## ...        ...       ...       ...
    ## 8684         1   4243.17      1114
    ## 8685         1   4244.74      1115
    ## 8686         1   4246.30      1116
    ## 8687         1   4247.87      1117
    ## 8688         1   4249.43      1118
    ##  ... 31 more variables/columns.
    ## 
    ## file(s):
    ## ko15.CDF
    ## ko16.CDF
    ## ko21.CDF
    ##  ... 5 more files
    ## Processing:
    ##  Filter: select retention time [2550..4250] on MS level(s)  [Wed Mar 12 08:35:51 2025]

Next to the alabaster-based stash format *xcmsStash* implements also a
*plain text file*-based format (`PlainTextParam`), that stores all data
as (human readable) tabulator delimited text files. Additional formats,
such as the possibility to save *xcms* results in mzTab-M format
(through the *[RmzTabM](https://bioconductor.org/packages/3.23/RmzTabM)*
package) will be added in future.

## Session information

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)`(``)`

    ## R version 4.6.1 (2026-06-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] alabaster.base_1.13.2 Spectra_1.23.3        S4Vectors_0.51.7     
    ##  [4] BiocGenerics_0.59.12  generics_0.1.4        fs_2.1.0             
    ##  [7] xcmsStash_0.97.1      MsStash_0.99.0        MsExperiment_1.15.0  
    ## [10] ProtGenerics_1.45.0   xcms_4.11.2           BiocParallel_1.47.0  
    ## [13] BiocStyle_2.40.0     
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] DBI_1.3.0                   rlang_1.3.0                
    ##   [3] magrittr_2.0.5              clue_0.3-68                
    ##   [5] MassSpecWavelet_1.79.2      otel_0.2.0                 
    ##   [7] matrixStats_1.5.0           compiler_4.6.1             
    ##   [9] PTMods_1.1.0                systemfonts_1.3.2          
    ##  [11] vctrs_0.7.3                 reshape2_1.4.5             
    ##  [13] stringr_1.6.0               crayon_1.5.3               
    ##  [15] pkgconfig_2.0.3             MetaboCoreUtils_1.21.1     
    ##  [17] fastmap_1.2.0               XVector_0.53.0             
    ##  [19] rmarkdown_2.31              preprocessCore_1.74.0      
    ##  [21] ragg_1.5.2                  purrr_1.2.2                
    ##  [23] xfun_0.60                   MultiAssayExperiment_1.39.0
    ##  [25] cachem_1.1.0                jsonlite_2.0.0             
    ##  [27] progress_1.2.3              rhdf5filters_1.25.4        
    ##  [29] DelayedArray_0.39.6         Rhdf5lib_2.1.0             
    ##  [31] prettyunits_1.2.0           parallel_4.6.1             
    ##  [33] cluster_2.1.8.3             R6_2.6.1                   
    ##  [35] bslib_0.12.0                stringi_1.8.9              
    ##  [37] RColorBrewer_1.1-3          limma_3.69.4               
    ##  [39] GenomicRanges_1.65.1        jquerylib_0.1.4            
    ##  [41] iterators_1.0.14            Rcpp_1.1.2                 
    ##  [43] Seqinfo_1.3.0               bookdown_0.47              
    ##  [45] SummarizedExperiment_1.43.0 knitr_1.51                 
    ##  [47] IRanges_2.47.2              Matrix_1.7-6               
    ##  [49] igraph_2.3.3                tidyselect_1.2.1           
    ##  [51] MsExperimentStash_0.97.3    abind_1.4-8                
    ##  [53] yaml_2.3.12                 doParallel_1.0.17          
    ##  [55] codetools_0.2-20            affy_1.91.0                
    ##  [57] lattice_0.23-1              tibble_3.3.1               
    ##  [59] plyr_1.8.9                  Biobase_2.73.2             
    ##  [61] S7_0.2.2                    evaluate_1.0.5             
    ##  [63] desc_1.4.3                  alabaster.schemas_1.13.0   
    ##  [65] pillar_1.11.1               affyio_1.83.0              
    ##  [67] BiocManager_1.30.27         MatrixGenerics_1.25.0      
    ##  [69] foreach_1.5.2               MSnbase_2.39.5             
    ##  [71] MALDIquant_1.22.3           ncdf4_1.24                 
    ##  [73] SpectraStash_0.99.1         hms_1.1.4                  
    ##  [75] ggplot2_4.0.3               scales_1.4.0               
    ##  [77] glue_1.8.1                  alabaster.matrix_1.12.0    
    ##  [79] MsFeatures_1.21.0           lazyeval_0.2.3             
    ##  [81] tools_4.6.1                 mzID_1.51.0                
    ##  [83] data.table_1.18.6.1         QFeatures_1.23.1           
    ##  [85] vsn_3.81.0                  mzR_2.47.0                 
    ##  [87] XML_3.99-0.24               rhdf5_2.57.12              
    ##  [89] grid_4.6.1                  impute_1.87.0              
    ##  [91] tidyr_1.3.2                 MsCoreUtils_1.25.4         
    ##  [93] PSMatch_1.17.0              HDF5Array_1.40.0           
    ##  [95] cli_3.6.6                   textshaping_1.0.5          
    ##  [97] S4Arrays_1.13.0             Chromatograms_1.3.3        
    ##  [99] dplyr_1.2.1                 AnnotationFilter_1.37.0    
    ## [101] pcaMethods_2.5.0            gtable_0.3.6               
    ## [103] sass_0.4.10                 digest_0.6.39              
    ## [105] SparseArray_1.13.2          htmlwidgets_1.6.4          
    ## [107] farver_2.1.2                htmltools_0.5.9            
    ## [109] pkgdown_2.2.1.9000          lifecycle_1.0.5            
    ## [111] h5mread_1.4.0               statmod_1.5.2              
    ## [113] MASS_7.3-66
