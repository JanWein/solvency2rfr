#' List available EIOPA RFR publications
#'
#' Fetches the EIOPA RSS feed and returns a tibble of all available
#' risk-free rate publications with their reference dates and download
#' URLs.
#'
#' @param feed_url The URL of the EIOPA RSS feed. Defaults to the official
#'   feed URL. Override only for testing.
#'
#' @return A [tibble::tibble()] with columns:
#'   - `date` (`Date`): The reference date of the publication (end of month).
#'   - `title` (`character`): The publication title (e.g. `"April 2026"`).
#'   - `url` (`character`): Direct download URL for the ZIP file.
#'
#' @details
#' The EIOPA RSS feed contains monthly RFR publications as well as
#' background documents (technical documentation, UFR reports, etc.).
#' `rfr_index()` filters the feed to return only the monthly ZIP
#' publications and excludes PDF, XLSX, and other document types.
#'
#' An internet connection is required.
#'
#' @examplesIf interactive()
#' idx <- rfr_index()
#' head(idx)
#'
#' @export
rfr_index <- function(feed_url = rfr_feed_url()) {
  xml <- rfr_fetch_xml(feed_url)
  items <- xml2::xml_find_all(xml, ".//item")

  urls <- xml2::xml_text(xml2::xml_find_all(items, "link"))
  titles <- xml2::xml_text(xml2::xml_find_all(items, "title"))
  pub_dates <- xml2::xml_text(xml2::xml_find_all(items, "pubDate"))

  # Keep only ZIP files (monthly RFR publications)
  is_zip <- grepl("\\.zip$", urls, ignore.case = TRUE)
  # Exclude financial stability and dual-run ZIPs (different format)
  is_fsr <- grepl("FSR_RFR", urls, ignore.case = TRUE)
  is_dual <- grepl("dual_run", urls, ignore.case = TRUE)
  keep <- is_zip & !is_fsr & !is_dual

  urls <- urls[keep]
  titles <- trimws(titles[keep])
  pub_dates <- pub_dates[keep]

  # Extract reference date from filename: EIOPA_RFR_YYYYMMDD.zip
  dates <- rfr_date_from_url(urls)

  tibble::tibble(
    date = dates,
    title = titles,
    url = urls
  )
}

#' @noRd
rfr_feed_url <- function() {
  "https://www.eiopa.europa.eu/feed/53/rss_en"
}

#' @noRd
rfr_fetch_xml <- function(url) {
  resp <- httr2::request(url) |>
    httr2::req_user_agent("solvency2rfr R package (https://github.com/JanWein/solvency2rfr)") |>
    httr2::req_timeout(30) |>
    httr2::req_perform()
  xml2::read_xml(httr2::resp_body_string(resp))
}

#' @noRd
rfr_date_from_url <- function(urls) {
  # Extract YYYYMMDD from filenames; pattern may have suffixes before .zip
  # e.g. EIOPA_RFR_20260430.zip or eiopa_rfr_20191231_0_0.zip
  m <- regmatches(urls, regexpr("_([0-9]{8})(?=[_.])", urls, perl = TRUE))
  # Strip leading underscore
  dates_str <- sub("^_", "", m)
  as.Date(ifelse(nchar(dates_str) == 8, dates_str, NA_character_), format = "%Y%m%d")
}
