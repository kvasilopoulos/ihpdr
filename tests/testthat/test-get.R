context("ihpd_get")

skip_if_offline()
skip_if_http_error()

test_that("get works", {
  expect_error(ihpd_get("raw"), NA)
  expect_error(ihpd_get("gsadf"), NA)
  expect_error(ihpd_get("bsadf"), NA)
})

test_that("older versions work", {
  expect_error(ihpd_get("raw", version = "1704"), NA)
  expect_error(ihpd_get("gsadf", version = "1704"), NA)
  expect_error(ihpd_get("bsadf", version = "1704"), NA)
})

test_that("wrong-version", {
  expect_error(ihpd_get("raw", version = "10-1"))
})
