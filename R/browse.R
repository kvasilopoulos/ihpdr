
#' Quickly browse to important links
#'
#' This function take you to webpages associated with the International House
#' Price Database. Option `app` take you the International Housing Observatory,
#' while `info` take you to Dallas Fed info page of the data.
#'
#' @param wat whether to browse the shiny `app` or the `info` page. Defaults at
#' `info`.
#'
#' @export
#'
#' @examples
#'
#' ihpd_browse()
ihpd_browse <- function(wat = c("app", "info")) {
  wat <- match.arg(wat)
  ihpd_url <- switch(
    wat,
    app = "https://lancs-macro.shinyapps.io/international-housing-observatory/",
    info =  "https://www.dallasfed.org/institute/houseprice#tab2"
  )
  utils::browseURL(ihpd_url)
}
