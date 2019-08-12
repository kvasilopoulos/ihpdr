
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ihpdr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/ihpdr)](https://CRAN.R-project.org/package=ihpdr)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/kvasilopoulos/ihpdr.svg?branch=master)](https://travis-ci.org/kvasilopoulos/ihpdr)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/kvasilopoulos/ihpdr?branch=master&svg=true)](https://ci.appveyor.com/project/kvasilopoulos/ihpdr)
<!-- badges: end -->

The goal of {ihpdr} is to fetch data from the [International Hous Price
Database](https://www.dallasfed.org/institute/houseprice#tab1), compiled
by the Federal Reserve Bank of Dallas.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kvasilopoulos/ihpdr")
```

## Example

This is a basic example which shows you how to download the data:

``` r
library(ihpdr)

# House Prices
download_raw()
#> # A tibble: 4,248 x 6
#>    Date       country     hpi  rhpi   pdi  rpdi
#>    <date>     <chr>     <dbl> <dbl> <dbl> <dbl>
#>  1 1975-01-01 Australia  7.60  39.2  14.1  72.2
#>  2 1975-04-01 Australia  7.74  38.5  14.4  71.4
#>  3 1975-07-01 Australia  8.04  38.6  14.7  70.6
#>  4 1975-10-01 Australia  8.29  37.7  15.2  69.6
#>  5 1976-01-01 Australia  8.58  37.9  15.5  69.1
#>  6 1976-04-01 Australia  8.83  38.1  15.9  69.5
#>  7 1976-07-01 Australia  9.07  38.3  17.1  71.2
#>  8 1976-10-01 Australia  9.25  37.9  17.4  71.1
#>  9 1977-01-01 Australia  9.48  37.9  17.7  70.7
#> 10 1977-04-01 Australia  9.66  37.7  18.0  70.2
#> # ... with 4,238 more rows

# Exuberance Indicators ~ gsadf
download_exuber()
#> # A tibble: 230 x 7
#>    country     var   tstat   lag   sig  value  crit
#>    <chr>       <chr> <chr> <dbl> <dbl>  <dbl> <dbl>
#>  1 Australia   rhpi  sadf      1   0.9 2.85   0.999
#>  2 Belgium     rhpi  sadf      1   0.9 0.940  0.999
#>  3 Canada      rhpi  sadf      1   0.9 2.66   0.999
#>  4 Switzerland rhpi  sadf      1   0.9 2.51   0.999
#>  5 Germany     rhpi  sadf      1   0.9 0.0450 0.999
#>  6 Denmark     rhpi  sadf      1   0.9 1.98   0.999
#>  7 Spain       rhpi  sadf      1   0.9 0.680  0.999
#>  8 Finland     rhpi  sadf      1   0.9 2.88   0.999
#>  9 France      rhpi  sadf      1   0.9 3.21   0.999
#> 10 UK          rhpi  sadf      1   0.9 2.73   0.999
#> # ... with 220 more rows

# Exuberance Indicators ~ bsadf
download_exuber("bsadf")
#> # A tibble: 4,071 x 7
#>    Date       crit_value country  rhpi_lag1 ratio_lag1 rhpi_lag4 ratio_lag4
#>    <date>          <dbl> <chr>        <dbl>      <dbl>     <dbl>      <dbl>
#>  1 1975-01-01         NA Austral~        NA         NA        NA         NA
#>  2 1975-04-01         NA Austral~        NA         NA        NA         NA
#>  3 1975-07-01         NA Austral~        NA         NA        NA         NA
#>  4 1975-10-01         NA Austral~        NA         NA        NA         NA
#>  5 1976-01-01         NA Austral~        NA         NA        NA         NA
#>  6 1976-04-01         NA Austral~        NA         NA        NA         NA
#>  7 1976-07-01         NA Austral~        NA         NA        NA         NA
#>  8 1976-10-01         NA Austral~        NA         NA        NA         NA
#>  9 1977-01-01         NA Austral~        NA         NA        NA         NA
#> 10 1977-04-01         NA Austral~        NA         NA        NA         NA
#> # ... with 4,061 more rows

# Get the release dates
ihpdr::release_dates()
#>   Last Quarter Included  Data Release Date
#> 2    First quarter 2019    July 8–12, 2019
#> 3   Second quarter 2019 October 7–11, 2019
#> 4    Third quarter 2019 January 6–10, 2020
#> 5   Fourth quarter 2019   April 6–10, 2020
```

-----

Please note that the ‘ihpdr’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
