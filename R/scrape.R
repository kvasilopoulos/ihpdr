#' @importFrom dplyr mutate full_join
#' @importFrom tidyr gather
#' @importFrom lubridate yq
#' @importFrom rlang !! enquo
clean_gather <- function(x, nm, ...) {
  x %>% dplyr::rename(Date = 1) %>%
    dplyr::mutate(Date = Date %>% lubridate::yq()) %>%
    tidyr::gather(country, !!enquo(nm), -Date, ...)
}

#' Download nternational House Price Database Data
#'
#' All releases of the database include the following time series for the
#' countries covered:
#' \itemize{
#'  \item The house price index (hpi).
#'  \item The house price index expressed in real terms (rhpi).
#'  \item The personal disposable income index (pdi).
#'  \item The personal disposable income expressed in real terms index (rpdi).
#' }
#' All variables in real terms are deflated with the personal consumption
#' expenditure (PCE) deflator.
#'
#' @importFrom httr GET write_disk
#' @importFrom rvest html_nodes html_attrs
#' @importFrom xml2 read_html
#' @importFrom readxl read_excel
#' @importFrom tidyr drop_na
#' @export
#'
#' @examples
#' download_raw()
#'
download_raw <- function() {

  relative_url <-
    xml2::read_html("https://www.dallasfed.org/institute/houseprice#tab2") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    grep(".xlsx$", ., value = TRUE) %>%
    `[`(1)

  absolute_url <- paste0("https://www.dallasfed.org", relative_url)

  tf <- tempfile(fileext = ".xlsx")
  httr::GET(absolute_url, write_disk(tf))

  suppressMessages({
    hpi <- readxl::read_excel(tf, sheet = 2)
    rhpi <- readxl::read_excel(tf, sheet = 3)
    pdi <- readxl::read_excel(tf, sheet = 4)
    rpdi <- readxl::read_excel(tf, sheet = 5)
  })

  list(
    clean_gather(hpi, hpi),
    clean_gather(rhpi, rhpi),
    clean_gather(pdi, pdi),
    clean_gather(rpdi, rpdi)) %>%
    reduce(full_join, by = c("Date", "country")) %>%
    drop_na()

}

#' Download nternational House Price Database Exuberance Data
#'
#' @param option which to download
#' @importFrom purrr reduce
#' @importFrom dplyr slice rename select mutate_at vars
#' @export
#'
#' @examples
#'
#' download_exuber(option = "gsadf")
#'
#' download_exuber(option = "bsadf")
#'
download_exuber <- function(option = c("gsadf", "bsadf")) {

  option <- match.arg(option)

  relative_url <-
    xml2::read_html("https://www.dallasfed.org/institute/houseprice#tab2") %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    grep(".xlsx$", ., value = TRUE) %>%
    `[`(2)

  absolute_url <- paste0("https://www.dallasfed.org", relative_url)

  tf <- tempfile(fileext = ".xlsx")
  httr::GET(absolute_url, httr::write_disk(tf))

  nms <- readxl::read_excel(tf, sheet = 2, range = "G2:AE2") %>%
    dplyr::rename(Date = DATE, crit_value = "95% CRITICAL VALUES") %>%
    names()

  suppressMessages({
    lag1 <- readxl::read_excel(tf, sheet = 2, skip = 1, na = c("", "NA"))
    lag4 <- readxl::read_excel(tf, sheet = 3, skip = 1, na = c("", "NA"))
  })

  if (option == "bsadf") {
    out <- list(
      lag1 %>%
        select(7:31) %>%
        slice(-1) %>%
        set_names(nms) %>%
        clean_gather("rhpi_lag1", -crit_value),
      lag1 %>%
        select(33:57) %>%
        slice(-1) %>%
        set_names(nms) %>%
        clean_gather("ratio_lag1", -crit_value),
      lag4 %>%
        select(7:31) %>%
        slice(-1) %>%
        set_names(nms) %>%
        clean_gather("rhpi_lag4", -crit_value),
      lag4 %>%
        select(33:57) %>%
        slice(-1) %>%
        set_names(nms) %>%
        clean_gather("ratio_lag4", -crit_value)) %>%
      reduce(full_join, by = c("Date", "crit_value", "country"))
  }else{

    cv <- lag1[3:5, 1:3] %>%
      set_names("sig", "sadf", "gsadf") %>%
      gather(tstat, crit, -sig)
    cv_seq_sadf_lag1 <- lag1[8:30, 1:3] %>%
      set_names("country", "sadf", "gsadf") %>%
      mutate(var = "rhpi", lag = 1) %>%
      mutate_at(vars(sadf, gsadf), as.numeric) %>%
      gather(tstat, value, -country, -var, -lag)
    cv_seq_gsadf_lag1 <- lag1[8:30, c(1,4:5)] %>%
      set_names("country", "sadf", "gsadf") %>%
      mutate(var = "ratio", lag = 1) %>%
      mutate_at(vars(sadf, gsadf), as.numeric) %>%
      gather(tstat, value, -country, -var, -lag)
    cv_seq_sadf_lag4 <- lag4[8:30, 1:3] %>%
      set_names("country", "sadf", "gsadf") %>%
      mutate(var = "rhpi", lag = 4) %>%
      mutate_at(vars(sadf, gsadf), as.numeric) %>%
      gather(tstat, value, -country, -var, -lag)
    cv_seq_gsadf_lag4 <- lag4[8:30, c(1,4:5)] %>%
      set_names("country", "sadf", "gsadf") %>%
      mutate(var = "ratio", lag = 4) %>%
      mutate_at(vars(sadf, gsadf), as.numeric) %>%
      gather(tstat, value, -country, -var, -lag)

    suppressMessages({
      out <- list(cv, cv_seq_sadf_lag1, cv_seq_gsadf_lag1,
                  cv_seq_sadf_lag4, cv_seq_sadf_lag4) %>%
        reduce(full_join) %>%
        select(country, var, tstat, lag, sig, value, crit) %>%
        mutate_at(vars(crit,sig), as.numeric)
    })
  }
  out
}

#' Fetches the latest release dates
#'
#'@export
#'@importFrom rvest html_table
#'@importFrom rlang set_names
release_dates <- function() {

  tbl <- xml2::read_html("https://www.dallasfed.org/institute/houseprice") %>%
    rvest::html_nodes("table") %>%
    rvest::html_table()

  tbl[[1]][-1, ] %>%
    set_names("Last Quarter Included", "Data Release Date")

}




