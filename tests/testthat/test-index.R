test_that("rfr_index returns correct structure when online", {
  skip_on_cran()
  skip_if_offline()

  idx <- rfr_index()

  expect_s3_class(idx, "tbl_df")
  expect_named(idx, c("date", "title", "url"))
  expect_s3_class(idx$date, "Date")
  expect_type(idx$title, "character")
  expect_type(idx$url, "character")
  expect_gt(nrow(idx), 0)
})

test_that("rfr_index regular publications are end-of-month dates", {
  skip_on_cran()
  skip_if_offline()

  idx <- rfr_index()

  # Regular monthly publications (title looks like "Month YYYY") are end-of-month.
  # Extraordinary COVID updates and old parallel files may be mid-month.
  regular <- idx[grepl("^[A-Za-z]+ [0-9]{4}$", idx$title), ]
  next_day <- regular$date + 1
  expect_true(all(as.integer(format(next_day, "%d")) == 1))
})

test_that("rfr_index URLs point to ZIP files", {
  skip_on_cran()
  skip_if_offline()

  idx <- rfr_index()
  expect_true(all(grepl("\\.zip$", idx$url, ignore.case = TRUE)))
})

test_that("rfr_date_from_url handles various filename formats", {
  urls <- c(
    "https://example.com/EIOPA_RFR_20260430.zip",
    "https://example.com/eiopa_rfr_20191231_0_0.zip",
    "https://example.com/eiopa_rfr_20191130_refinitiv_data.zip",
    "https://example.com/eiopa_rfr_20200512_0.zip"
  )
  dates <- solvency2rfr:::rfr_date_from_url(urls)

  expect_s3_class(dates, "Date")
  expect_equal(dates, as.Date(c(
    "2026-04-30", "2019-12-31", "2019-11-30", "2020-05-12"
  )))
})
