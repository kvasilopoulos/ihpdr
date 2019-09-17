#' @importFrom httr GET write_disk
#' @importFrom rvest html_nodes html_attrs
#' @importFrom xml2 read_html
ihpd_tf <- function(file = 1) {
  relative_url <-
    xml2::read_html("https://www.dallasfed.org/institute/houseprice#tab2") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    grep(".xlsx$", ., value = TRUE) %>%
    magrittr::extract(file)

  absolute_url <- paste0("https://www.dallasfed.org", relative_url)

  tf <- tempfile(fileext = ".xlsx")
  httr::GET(absolute_url, write_disk(tf))
  tf
}


#' @importFrom dplyr mutate full_join
#' @importFrom lubridate yq
#' @importFrom rlang !! enquo
format_excel_raw <- function(x, sheet_num, nm, ...) {
  suppressMessages({
    read_excel(x, sheet = sheet_num) %>%
      dplyr::rename(Date = 1) %>%
      dplyr::mutate(Date = Date %>% lubridate::yq()) %>%
      tidyr::gather(country, !!enquo(nm), -Date, ...)
  })
}

#' @importFrom readxl read_excel
#' @importFrom tidyr drop_na gather
ihpd_get_raw <- function() {

  tf <- ihpd_tf(file = 1)
  on.exit(file.remove(tf))

  list(
    format_excel_raw(tf, 2, "hpi"),
    format_excel_raw(tf, 3, "rhpi"),
    format_excel_raw(tf, 4, "pdi"),
    format_excel_raw(tf, 5, "rpdi")) %>%
    reduce(full_join, by = c("Date", "country")) %>%
    drop_na()
}


format_excel_bsadf <- function(x, nm, nms, ...) {
  x %>% slice(-1) %>% set_names(nms) %>%
    dplyr::rename(Date = 1) %>%
    dplyr::mutate(Date = Date %>% lubridate::yq()) %>%
    tidyr::gather(country, !!enquo(nm), -Date, -crit, ...)
}


ihpd_get_bsadf <- function() {

  tf <- ihpd_tf(file = 2)
  on.exit(file.remove(tf))

  nms <- readxl::read_excel(tf, sheet = 2, range = "G2:AE2") %>%
    dplyr::rename(Date = DATE, crit = "95% CRITICAL VALUES") %>%
    names()

  suppressMessages({
    lag1 <- readxl::read_excel(tf, sheet = 2, skip = 1, na = c("", "NA"))
    lag4 <- readxl::read_excel(tf, sheet = 3, skip = 1, na = c("", "NA"))
  })

  tbl_lag1 <-
    list(
      format_excel_bsadf(lag1[,7:31], nm = "rhpi", nms),
      format_excel_bsadf(lag1[,33:57], nm = "ratio", nms)
      ) %>%
    reduce(full_join, by = c("Date", "crit", "country")) %>%
    mutate(lag = 1) %>%
    gather(type, value, -Date, -country, -crit, -lag)

  tbl_lag4 <-
    list(
      format_excel_bsadf(lag4[, 7:31], nm = "rhpi", nms),
      format_excel_bsadf(lag4[, 33:57], nm = "ratio", nms)
    ) %>%
    reduce(full_join, by = c("Date", "crit", "country")) %>%
    mutate(lag = 4) %>%
    gather(type, value, -Date, -country, -crit, -lag)

   full_join(tbl_lag1, tbl_lag4,
             by = c("country", "Date", "crit", "type", "lag", "value")) %>%
     select(Date, country, type, lag, value, crit)
}

format_excel_sadf <- function(x) {
  x
}

format_excel_gsadf <- function(x, nm, lag = 1) {
  x %>%
    set_names("country", "sadf", "gsadf") %>%
    mutate(type = nm, lag = lag) %>%
    mutate_at(vars(sadf, gsadf), as.numeric) %>%
    gather(tstat, value, -country, -type, -lag)
}

ihpd_get_gsadf <- function() {

  tf <- ihpd_tf(file = 2)
  on.exit(file.remove(tf))

  nms <- readxl::read_excel(tf, sheet = 2, range = "G2:AE2") %>%
    dplyr::rename(Date = DATE, crit = "95% CRITICAL VALUES") %>%
    names()

  suppressMessages({
    lag1 <- readxl::read_excel(tf, sheet = 2, skip = 1, na = c("", "NA"))
    lag4 <- readxl::read_excel(tf, sheet = 3, skip = 1, na = c("", "NA"))
  })

  cv <- lag1[3:5, 1:3] %>%
    set_names("sig", "sadf", "gsadf") %>%
    gather(tstat, crit, -sig)

  list(
    format_excel_gsadf(lag1[8:30, 1:3], "rhpi", lag = 1),
    format_excel_gsadf(lag1[8:30, c(1,4:5)], "ratio", lag = 1),
    format_excel_gsadf(lag4[8:30, 1:3], "rhpi", lag = 1),
    format_excel_gsadf(lag4[8:30, c(1,4:5)], "ratio", lag = 1)
       ) %>%
    reduce(full_join, by = c("tstat", "country", "type", "lag", "value")) %>%
    full_join(cv, by = "tstat") %>%
    mutate_at(vars(crit, sig), as.numeric) %>%
    select(country, type, tstat, lag, value, crit, sig)

}

#' Download International House Price Database Data
#'
#' Available downloads:
#' \enumerate{
#'   \item raw: Raw Data
#'   \item gsadf: Generalized sup ADF statistics
#'   \item bsadf: Backward sup ADF statistic sequence
#'  }
#'
#' @param symbol which dataset to download.
#'
#' @details
#'
#' \describe{
#'   \item{raw}{
#'
#'Includes the following time series for the countries covered:
#' \itemize{
#'  \item hpi: The house price index.
#'  \item rhpi: The house price index expressed in real terms.
#'  \item pdi: The personal disposable income index.
#'  \item rpdi: The personal disposable income expressed in real terms index.
#' }
#' All variables in real terms are deflated with the personal consumption
#' expenditure (PCE) deflator.}
#' }
#'
#'The exuberance indicators include
#'\describe{
#' \item{gsadf}{
#'   \itemize{
#'     \item type: real house price index (rhpi) and the ratio of rhpi to real
#'     personal disposable income (rpdi)
#'     \item lag: lag length of 1 and 4
#'     \item sig: significance level for the critical value
#'     \item value: test statistics for explosive behavior
#'     \item crit: 95 percent critical values.
#'  }
#' }
#'
#' \item{bsadf}{
#'   The exuberance indicators include
#'   \itemize{
#'     \item type: real house price index (rhpi) and the ratio of rhpi to real
#'     personal disposable income (rpdi)
#'     \item lag: lag length of 1 and 4,
#'     \item value: test statistics for explosive behavior
#'     \item crit: 95 percent critical values.
#'     }
#'  }
#' }
#'
#' @importFrom purrr reduce
#' @importFrom dplyr slice rename select mutate_at vars
#' @export
#'
#' @examples
#'
#' ihpd_get()
ihpd_get <- function(symbol = c("raw", "gsadf", "bsadf")) {
  symbol <- match.arg(symbol)
  switch(symbol,
    raw = ihpd_get_raw(),
    gsadf = ihpd_get_gsadf(),
    bsadf = ihpd_get_bsadf()
    )
}

#' Fetches the latest release dates
#'
#'@export
#'@importFrom rvest html_table
#'@importFrom rlang set_names
ihpd_release_dates <- function() {

  tbl <- xml2::read_html("https://www.dallasfed.org/institute/houseprice") %>%
    rvest::html_nodes("table") %>%
    rvest::html_table()

  tbl[[1]][-1, ] %>%
    set_names("Last Quarter Included", "Data Release Date")
}
