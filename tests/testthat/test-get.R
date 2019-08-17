test_that("get works", {
  expect_error(ihpd_get("raw"), NA)
  expect_error(ihpd_get("gsadf"), NA)
  expect_error(ihpd_get("bsadf"), NA)
})
