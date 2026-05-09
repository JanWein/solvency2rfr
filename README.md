# solvency2rfr

<!-- badges: start -->
<!-- badges: end -->

`solvency2rfr` provides tidy access to the monthly risk-free interest rate (RFR)
term structures published by EIOPA for Solvency II calculations.

## Installation

Once on CRAN:

```r
install.packages("solvency2rfr")
```

Development version from GitHub:

```r
# install.packages("pak")
pak::pkg_install("JanWein/solvency2rfr")
```

## Usage

```r
library(solvency2rfr)

# List available publications
idx <- rfr_index()
head(idx)
#> # A tibble: 6 × 3
#>   date       title         url                                                         
#>   <date>     <chr>         <chr>                                                       
#> 1 2026-04-30 April 2026    https://www.eiopa.europa.eu/system/files/…/EIOPA_RFR_….zip
#> 2 2026-03-31 March 2026    https://www.eiopa.europa.eu/system/files/…/EIOPA_RFR_….zip
#> …

# Download the most recent term structures
rfr <- rfr_term_structures()

# Or for a specific date
rfr_april <- rfr_term_structures("2026-04-30")
rfr_april
#> # A tibble: 6,150 × 4
#>   date       country  maturity   rate
#>   <date>     <chr>       <int>  <dbl>
#> 1 2026-04-30 Euro            1 0.0268
#> 2 2026-04-30 Euro            2 0.0275
#> …

# With volatility adjustment
rfr_va <- rfr_term_structures("2026-04-30", curve = "spot_with_VA")
```

Available `curve` types: `"spot_no_VA"` (default), `"spot_with_VA"`,
`"spot_no_VA_up"`, `"spot_no_VA_down"`, `"spot_with_VA_up"`, `"spot_with_VA_down"`.

## Data source

EIOPA publishes RFR term structures monthly at:
<https://www.eiopa.europa.eu/tools-and-data/risk-free-interest-rate-term-structures_en>

EIOPA accepts no responsibility for losses incurred in reliance on this data.

## License

MIT © solvency2rfr authors
