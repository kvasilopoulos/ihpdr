
#' Quickly browse to important links
#'
#' This function take you to webpages associated with the International House
#' Price Database and returns the url invisibly. Option `app` take you the
#' International Housing Observatory, while `info` take you to Dallas Fed
#' info page of the data.
#'
#' @param pick whether to browse the shiny `info` or the `app` page. Defaults at
#' `info`.
#'
#' @export
#'
#' @examples
#'
#' ihpd_browse()
ihpd_browse <- function(pick = c("info", "app")) {
  pick <- match.arg(pick)
  view_url(pick_url(pick))
}

pick_url <- function(pick) {
  ihpd_url <- switch(
    pick,
    app = "https://lancs-macro.shinyapps.io/international-housing-observatory/",
    info =  "https://www.dallasfed.org/institute/houseprice#tab2"
  )
}

view_url <- function(ihpd_url, open = interactive()) {
  if (open) {
    utils::browseURL(ihpd_url)
  }
  invisible(ihpd_url)
}
