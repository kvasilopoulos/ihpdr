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


test_that("bsadf has the right elements",{
  bsadf <- ihpd_get("bsadf")
  countries <- unique(bsadf$country)
  lags <- unique(bsadf$lag)
  start_date <- bsadf$Date[1]
  expect_false(all(startsWith(countries, "Aggregate")))
  expect_true(all(lags %in% c(1,4)))
  expect_true(start_date == "1975-01-01")
})

test_that("bsadf has the right elements",{
  gsadf <- ihpd_get("gsadf")
  countries <- unique(bsadf$country)
  lags <- unique(bsadf$lag)
  sig <- unique(gsadf$sig)
  expect_false(all(startsWith(countries, "Aggregate")))
  expect_true(all(lags %in% c(1,4)))
  expect_true(all(sig %in% c(0.90, 0.95, 0.99)))
})
