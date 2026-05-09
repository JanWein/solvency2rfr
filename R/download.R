## Curve type -> Excel sheet name mapping
CURVE_SHEETS <- c(
  spot_no_VA = "RFR_spot_no_VA",
  spot_with_VA = "RFR_spot_with_VA",
  spot_no_VA_up = "Spot_NO_VA_shock_UP",
  spot_no_VA_down = "Spot_NO_VA_shock_DOWN",
  spot_with_VA_up = "Spot_WITH_VA_shock_UP",
  spot_with_VA_down = "Spot_WITH_VA_shock_DOWN"
)

#' Download EIOPA RFR term structures as a tidy tibble
#'
#' Downloads the monthly ZIP file for a given reference date, extracts
#' the `Term_Structures.xlsx` file, and returns the selected interest
#' rate curve as a tidy tibble.
#'
#' @param date A `Date` object or a character string in `"YYYY-MM-DD"` format
#'   specifying the reference date (end of month). Use [rfr_index()] to see
#'   available dates. Defaults to the most recent available publication.
#' @param curve One of `"spot_no_VA"` (default), `"spot_with_VA"`,
#'   `"spot_no_VA_up"`, `"spot_no_VA_down"`, `"spot_with_VA_up"`,
#'   `"spot_with_VA_down"`. Selects which rate curve to return.
#' @param feed_url The URL of the EIOPA RSS feed. Rarely needs to be changed.
#'
#' @return A [tibble::tibble()] with columns:
#'   - `date` (`Date`): The reference date.
#'   - `country` (`character`): Country or currency area name
#'     (e.g. `"Euro"`, `"Germany"`, `"Switzerland"`).
#'   - `maturity` (`integer`): Maturity in years (1 to 150).
#'   - `rate` (`double`): Annual spot rate as a decimal
#'     (e.g. `0.0268` for 2.68 %).
#'
#' @details
#' The EIOPA RFR term structures are published around the 5th of each month
#' for the previous month-end. An internet connection is required.
#'
#' Rates are returned as decimals, not percentages.
#'
#' @seealso [rfr_index()] to list all available publications.
#'
#' @examplesIf interactive()
#' # Get the most recent term structures
#' rfr <- rfr_term_structures()
#' head(rfr)
#'
#' # Get a specific month
#' rfr <- rfr_term_structures("2026-04-30")
#'
#' # Get the curve including volatility adjustment
#' rfr_va <- rfr_term_structures(curve = "spot_with_VA")
#'
#' @export
rfr_term_structures <- function(date = NULL, curve = "spot_no_VA",
                                feed_url = rfr_feed_url()) {
  curve <- match.arg(curve, names(CURVE_SHEETS))
  sheet <- CURVE_SHEETS[[curve]]

  index <- rfr_index(feed_url = feed_url)

  if (is.null(date)) {
    row <- index[which.max(index$date), ]
  } else {
    date <- as.Date(date)
    row <- index[index$date == date, ]
    if (nrow(row) == 0) {
      cli_abort(c(
        "No RFR publication found for date {.val {date}}.",
        i = "Use {.fn rfr_index} to see available dates."
      ))
    }
  }

  ref_date <- row$date[[1]]
  zip_url <- row$url[[1]]

  rfr_parse_zip(zip_url, sheet = sheet, ref_date = ref_date)
}

#' @noRd
rfr_parse_zip <- function(zip_url, sheet, ref_date) {
  tmp_zip <- tempfile(fileext = ".zip")
  on.exit(unlink(tmp_zip), add = TRUE)

  httr2::request(zip_url) |>
    httr2::req_user_agent("solvency2rfr R package (https://github.com/JanWein/solvency2rfr)") |>
    httr2::req_timeout(120) |>
    httr2::req_perform(path = tmp_zip)

  exdir <- tempfile()
  dir.create(exdir)
  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)

  utils::unzip(tmp_zip, exdir = exdir)

  xlsx_files <- list.files(exdir, pattern = "Term_Structures\\.xlsx$",
                           full.names = TRUE, ignore.case = TRUE)
  if (length(xlsx_files) == 0) {
    stop("Could not find Term_Structures.xlsx in the downloaded ZIP file.")
  }

  rfr_read_term_sheet(xlsx_files[[1]], sheet = sheet, ref_date = ref_date)
}

#' @noRd
rfr_read_term_sheet <- function(path, sheet, ref_date) {
  # Read without column names; suppress messages from readxl
  raw <- suppressMessages(
    readxl::read_excel(path, sheet = sheet, col_names = FALSE)
  )

  # Row 1: country/currency labels; col 1 is "Main menu" or similar -> skip
  countries <- as.character(unlist(raw[1, -1]))
  # Remove trailing whitespace
  countries <- trimws(countries)

  # Find data rows: col 1 must be numeric (maturity year 1–150)
  col1 <- suppressWarnings(as.numeric(unlist(raw[, 1])))
  data_rows <- which(!is.na(col1) & col1 >= 1 & col1 <= 150)

  mat_vals <- as.integer(col1[data_rows])
  rate_mat <- raw[data_rows, -1]

  # Build tidy tibble via base R (no tidyr dependency)
  n_mat <- length(mat_vals)
  n_ctry <- length(countries)

  out_date <- rep(ref_date, n_mat * n_ctry)
  out_country <- rep(countries, each = n_mat)
  out_maturity <- rep(mat_vals, times = n_ctry)
  out_rate <- numeric(n_mat * n_ctry)

  for (j in seq_len(n_ctry)) {
    col_vals <- suppressWarnings(as.numeric(unlist(rate_mat[, j])))
    out_rate[((j - 1) * n_mat + 1):(j * n_mat)] <- col_vals
  }

  tibble::tibble(
    date = out_date,
    country = out_country,
    maturity = out_maturity,
    rate = out_rate
  )
}

#' @noRd
cli_abort <- function(msg, ...) {
  stop(paste(msg, collapse = "\n"), call. = FALSE)
}
