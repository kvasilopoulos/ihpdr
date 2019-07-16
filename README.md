
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ihpdr

<!-- badges: start -->

<!-- badges: end -->

The goal of ihpdr is to fetch data from the [International Hous Price
Database](https://www.dallasfed.org/institute/houseprice#tab1), compiled
by the Federal Reserve Bank of Dallas.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kvasilopoulos/ihpdr")
```

## Example

This is a basic example which shows you how download raw data:

``` r
library(ihpdr)
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
```
