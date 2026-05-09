# solvency2rfr (development version)

# solvency2rfr 0.1.0

* Initial release.
* `rfr_index()` lists all available EIOPA RFR publications from the official RSS feed.
* `rfr_term_structures()` downloads and returns a tidy tibble of spot rates for a
  given reference date and curve type (`"spot_no_VA"`, `"spot_with_VA"`, and four
  stress scenarios).
