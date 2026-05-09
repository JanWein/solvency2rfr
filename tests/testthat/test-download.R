test_that("rfr_term_structures returns correct structure when online", {
  skip_on_cran()
  skip_if_offline()

  # Use a specific past date to keep tests reproducible
  rfr <- rfr_term_structures("2026-04-30")

  expect_s3_class(rfr, "tbl_df")
  expect_named(rfr, c("date", "country", "maturity", "rate"))
  expect_s3_class(rfr$date, "Date")
  expect_type(rfr$country, "character")
  expect_type(rfr$maturity, "integer")
  expect_type(rfr$rate, "double")
})

test_that("rfr_term_structures has correct dimensions", {
  skip_on_cran()
  skip_if_offline()

  rfr <- rfr_term_structures("2026-04-30")

  expect_equal(unique(rfr$date), as.Date("2026-04-30"))
  # 150 maturities per country
  expect_equal(sort(unique(rfr$maturity)), 1:150)
  # Multiple countries
  expect_gt(length(unique(rfr$country)), 10)
  # Rows = countries * maturities
  expect_equal(nrow(rfr), length(unique(rfr$country)) * 150)
})

test_that("rfr_term_structures rates are plausible", {
  skip_on_cran()
  skip_if_offline()

  rfr <- rfr_term_structures("2026-04-30", curve = "spot_no_VA")

  # Rates should be in a reasonable range (-0.1 to 0.2 for Solvency II)
  non_na <- rfr$rate[!is.na(rfr$rate)]
  expect_true(all(non_na > -0.1 & non_na < 0.2))
})

test_that("rfr_term_structures errors for unknown date", {
  skip_on_cran()
  skip_if_offline()

  expect_error(
    rfr_term_structures("2099-01-31"),
    regexp = "No RFR publication found"
  )
})

test_that("rfr_term_structures accepts all valid curve types", {
  skip_on_cran()
  skip_if_offline()

  curves <- c("spot_no_VA", "spot_with_VA")
  for (cv in curves) {
    rfr <- rfr_term_structures("2026-04-30", curve = cv)
    expect_s3_class(rfr, "tbl_df")
  }
})

test_that("rfr_term_structures rejects invalid curve type", {
  expect_error(
    rfr_term_structures(curve = "invalid_curve"),
    regexp = "should be one of"
  )
})
