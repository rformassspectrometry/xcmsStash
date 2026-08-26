# `XcmsExperiment` Stash

`XcmsExperiment` *xcms* result objects can be stored to (or read from)
*XcmsExperimentStash*es using the `saveMsObject()` and `readMsObject()`
functions which take a second argument `parameter` to select and
configure the format of the stash. The XcmsExperimentStash extends the
[MsExperimentStash::MsExperimentStash](https://rdrr.io/pkg/MsExperimentStash/man/MsExperimentStash.html)
defined in the *MsExperimentStash* package, i.e., it shares the same
content, but adds the *xcms* preprocessing results to it.

The supported stash formats are listed in the sections below.

## Usage

``` r
# S4 method for class 'XcmsExperiment,PlainTextParam'
saveMsObject(object, param, ...)

# S4 method for class 'XcmsExperiment,PlainTextParam'
readMsObject(object, param, ...)

# S4 method for class 'XcmsExperiment'
saveObject(x, path, ...)

# S4 method for class 'XcmsExperiment,AlabasterParam'
saveMsObject(object, param, ...)

# S4 method for class 'XcmsExperiment,AlabasterParam'
readMsObject(object, param, ...)
```

## Arguments

- object:

  A `XcmsExperiment` object.

- param:

  The parameter object to select and configure the stash format. Either
  [MsStash::AlabasterParam](https://rdrr.io/pkg/MsStash/man/AlabasterParam.html)
  or
  [MsStash::PlainTextParam](https://rdrr.io/pkg/MsStash/man/PlainTextParam.html).

- ...:

  For `saveMsObject()`: optional arguments passed down to the
  `saveMsObject()` function to stash the `Spectra` object (if present),
  such as `consolidate`. For `readMsObject()`: optional arguments for
  the `readMsObject()` call to restore the `Spectra` object (such as
  `spectraPath`). See
  [SpectraStash::SpectraStash](https://rdrr.io/pkg/SpectraStash/man/SpectraStash.html)
  for more information.

- x:

  A `XcmsExperiment` object.

- path:

  For `saveObject()`:

## Note

Overwriting an existing *XcmsExperimentStash* is not allowed.

## *alabaster*-based format, `AlabasterParam`

This alabster stash format is the most complete and reliable way for
long-term (and portable) storage of an `XcmsExperiment`. Objects can be
saved or read from this stash format either using the `saveMsObject()`
and `readMsObject()` functions together with an `AlabasterParam` object
or also using the
[`alabaster.base::saveObject()`](https://rdrr.io/pkg/alabaster.base/man/saveObject.html)
and
[`alabaster.base::readObject()`](https://rdrr.io/pkg/alabaster.base/man/readObject.html)
functions from the *alabaster.base* package. The alabaster stash format
for `XcmsExperiment` extends the
[MsExperimentStash::MsExperimentStash](https://rdrr.io/pkg/MsExperimentStash/man/MsExperimentStash.html).
Storage of the object's MS data and sample information is handled by the
functions of the
[MsExperimentStash::MsExperimentStash](https://rdrr.io/pkg/MsExperimentStash/man/MsExperimentStash.html)
with the *xcms* preprocessing results being added to the stash. Data
from the object's slots are stored to respective folders (using
alabaster functionality). Refer to the documentation of the
[MsExperimentStash::MsExperimentStash](https://rdrr.io/pkg/MsExperimentStash/man/MsExperimentStash.html)
for information on the format of the stored MS data and sample
information. *xcms*-specific data/folders are:

- *chrom_peaks*: the identified chromatographic peaks
  ([`chromPeaks()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)),
  stored as a numeric HDF5 array.

- *chrom_peak_data*: the data from the object's
  [`chromPeakData()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html),
  saved in HDF5 format.

- *feature_definitions*: the object's
  [`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html),
  saved in HDF5 format.

- *xcms_experiment_process_history.json*: the object's
  [`processHistory()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)
  serialized as a JSON object.

## Text file-based format, `PlainTextParam`

`saveMsObject()`/`readMsObject()` with `PlainTextParam` allows to save
and read *xcms* result objects from a text file-based stash. All
preprocessing results are stored in separate tabulator delimited text
files. Each of these files has the row names (representing either the
chromatographic peak IDs or feature IDs) written as first column and the
column names as first row. The files grouped by preprocessing result
are:

- Chromatographic peak detection results are stored in
  *xcms_experiment_chrom_peaks.txt*
  ([`chromPeaks()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html))
  and *xcms_experiment_chrom_peak_data.txt*
  ([`chromPeakData()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html)).

- Correspondence results: the definitions of the LC-MS features
  ([`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html))
  are stored to *xcms_experiment_feature_definitions.txt* (one row per
  feature) and the assignment between chromatographic peaks and features
  (the `$peakidx` column of
  [`featureDefinitions()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html))
  to *xcms_experiment_feature_peak_index.txt*, with one row for each
  mapping of a chromatographic peak to a feature. These files are not
  created (or present in the stash) if no correspondence analysis was
  performed.

- The processing history
  ([`processHistory()`](https://rdrr.io/pkg/xcms/man/XCMSnExp-class.html))
  is stored in JSON format to *xcms_experiment_process_history.json*.

## Author

Philippine Louail, Johannes Rainer

## Examples

``` r

## Load the example xcms result object
library(xcms)
#> Loading required package: BiocParallel
#> 
#> This is xcms version 4.11.2 
library(Spectra)
#> Loading required package: S4Vectors
#> Loading required package: stats4
#> Loading required package: BiocGenerics
#> Loading required package: generics
#> 
#> Attaching package: ‘generics’
#> The following objects are masked from ‘package:base’:
#> 
#>     as.difftime, as.factor, as.ordered, intersect, is.element, setdiff,
#>     setequal, union
#> 
#> Attaching package: ‘BiocGenerics’
#> The following objects are masked from ‘package:stats’:
#> 
#>     IQR, mad, sd, var, xtabs
#> The following object is masked from ‘package:utils’:
#> 
#>     data
#> The following objects are masked from ‘package:base’:
#> 
#>     Filter, Find, Map, Position, Reduce, anyDuplicated, aperm, append,
#>     as.data.frame, basename, cbind, colnames, dirname, do.call,
#>     duplicated, eval, evalq, get, grep, grepl, is.unsorted, lapply,
#>     mapply, match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     rank, rbind, rownames, sapply, saveRDS, scale, sequence, table,
#>     tapply, transform, unique, unsplit, which.max, which.min
#> 
#> Attaching package: ‘S4Vectors’
#> The following object is masked from ‘package:utils’:
#> 
#>     findMatches
#> The following objects are masked from ‘package:base’:
#> 
#>     I, expand.grid, unname
#> 
#> Attaching package: ‘Spectra’
#> The following object is masked from ‘package:xcms’:
#> 
#>     pickPeaks
library(MsExperiment)
#> Loading required package: ProtGenerics
#> 
#> Attaching package: ‘ProtGenerics’
#> The following object is masked from ‘package:stats’:
#> 
#>     smooth
xmse <- loadXcmsData()

## Ensure all parameter objects in the object's process history are in
## the latest format.
xmse@processHistory <- lapply(xmse@processHistory, function(z) {
    z@param <- updateObject(z@param)
    z
})

## Define the path where to create the XcmsExperimentStash
d <- file.path(tempdir(), "xcms_stash")

## Save the XcmsExperiment to a stash in alabaster format; Note: with
## `consolidate = TRUE` the MS data files are also **copied** into the
## stash
saveMsObject(xmse, AlabasterParam(d), consolidate = TRUE)

## Show the content of the stash folder
library(fs)
#> 
#> Attaching package: ‘fs’
#> The following object is masked from ‘package:BiocGenerics’:
#> 
#>     path
dir_tree(d)
#> /tmp/Rtmpa7zbc9/xcms_stash
#> ├── OBJECT
#> ├── _environment.json
#> ├── chrom_peak_data
#> │   ├── OBJECT
#> │   └── basic_columns.h5
#> ├── chrom_peaks
#> │   ├── OBJECT
#> │   └── array.h5
#> ├── experiment_files
#> │   ├── OBJECT
#> │   └── x
#> │       ├── OBJECT
#> │       └── list_contents.json.gz
#> ├── feature_definitions
#> │   ├── OBJECT
#> │   ├── basic_columns.h5
#> │   └── other_columns
#> │       └── 9
#> │           ├── OBJECT
#> │           └── list_contents.json.gz
#> ├── metadata
#> │   ├── OBJECT
#> │   └── list_contents.json.gz
#> ├── other_data
#> │   ├── OBJECT
#> │   └── list_contents.json.gz
#> ├── sample_data
#> │   ├── OBJECT
#> │   └── basic_columns.h5
#> ├── sample_data_links
#> │   ├── OBJECT
#> │   ├── list_contents.json.gz
#> │   └── other_contents
#> │       └── 0
#> │           ├── OBJECT
#> │           └── array.h5
#> ├── sample_data_links_mcols
#> │   ├── OBJECT
#> │   └── basic_columns.h5
#> ├── spectra
#> │   ├── OBJECT
#> │   ├── backend
#> │   │   ├── KO
#> │   │   │   ├── ko15.CDF
#> │   │   │   ├── ko16.CDF
#> │   │   │   ├── ko21.CDF
#> │   │   │   └── ko22.CDF
#> │   │   ├── OBJECT
#> │   │   ├── WT
#> │   │   │   ├── wt15.CDF
#> │   │   │   ├── wt16.CDF
#> │   │   │   ├── wt21.CDF
#> │   │   │   └── wt22.CDF
#> │   │   └── spectra_data
#> │   │       ├── OBJECT
#> │   │       └── basic_columns.h5
#> │   ├── metadata
#> │   │   ├── OBJECT
#> │   │   └── list_contents.json.gz
#> │   ├── processing
#> │   │   ├── OBJECT
#> │   │   └── contents.h5
#> │   ├── processing_chunk_size
#> │   │   ├── OBJECT
#> │   │   └── contents.h5
#> │   ├── processing_queue_variables
#> │   │   ├── OBJECT
#> │   │   └── contents.h5
#> │   └── spectra_processing_queue.json
#> └── xcms_experiment_process_history.json

## Read the MsExperiment from the stash (without xcms preprocessing results)
res <- readMsObject(MsExperiment(), AlabasterParam(d))
res
#> Object of class MsExperiment 
#>  Spectra: MS1 (8688) 
#>  Experiment data: 8 sample(s)
#>  Sample data links:
#>   - spectra: 8 sample(s) to 8688 element(s).

## Read the full xcms result object
res <- readMsObject(XcmsExperiment(), AlabasterParam(d))

## Show the first identified chromatographic peaks
chromPeaks(res) |> head()
#>           mz mzmin mzmax       rt    rtmin    rtmax     into     intb  maxo sn
#> CP0001 594.0 594.0 594.0 2607.809 2587.465 2643.803 161042.2 146073.3  7850 11
#> CP0002 577.0 577.0 577.0 2610.939 2587.465 2632.848 136105.2 128067.9  6215 11
#> CP0003 307.0 307.0 307.0 2625.024 2598.419 2651.628 284782.4 264907.0 16872 20
#> CP0004 302.0 302.0 302.0 2623.459 2601.549 2646.933 687146.6 669778.1 30552 43
#> CP0005 370.1 370.1 370.1 2679.797 2650.063 2706.592 449284.6 417225.3 25672 17
#> CP0006 427.0 427.0 427.0 2681.362 2650.063 2690.804 283334.7 263943.2 11025 13
#>        sample
#> CP0001      1
#> CP0002      1
#> CP0003      1
#> CP0004      1
#> CP0005      1
#> CP0006      1
```
