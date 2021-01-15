try_GET <- function(x, ...) {
  tryCatch(
    GET(url = x, timeout(10), ...),
    error = function(e) conditionMessage(e),
    warning = function(w) conditionMessage(w)
  )
}
is_response <- function(x) {
  class(x) == "response"
}

ihpd_files <- function(regex = "hp[0-9]") {
  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }
  remote <- "https://www.dallasfed.org/institute/houseprice#tab2"
  resp <- try_GET(remote)
  if (!is_response(resp)) {
    message(resp)
    return(invisible(NULL))
  }
  if (httr::http_error(resp)) { # network is down = message (not an error anymore)
    httr::message_for_status(resp)
    return(invisible(NULL))
  }
  resp

  xml2::read_html(resp) %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    grep(".xlsx$", ., value = TRUE) %>%
    grep(regex, ., value = TRUE)

}

# GET File ----------------------------------------------------------------

#' @importFrom httr GET write_disk timeout
#' @importFrom rvest html_nodes html_attrs html_attr
#' @importFrom xml2 read_html
#' @importFrom rlang %||%
ihpd_tf <- function(version = NULL, regex = "hp[0-9]", access_info = FALSE){

  search_url <- ihpd_files(regex = regex)

  if (is.null(version)) {
    relative_url <- search_url[1]
  } else {
    type <- gsub("\\[0-9]", "", regex)
    versions <- gsub(paste0(".*",type, "(.+)",".xlsx"), "\\1", search_url)
    if (!version %in% versions) {
      versions_mgs <- paste0(sQuote(versions, FALSE), collapse = " ")
      error_msg <- paste("wrong version number should be one of", versions_mgs)
      stop(error_msg, call. = FALSE)
    }
    relative_url <- grep(version, search_url, value = TRUE)
  }

  url <- paste0("https://www.dallasfed.org", relative_url)

  if (interactive() && access_info) {
    message("Accessing ", url)
  }
  tf <- tempfile(fileext = ".xlsx")
  resp_file <- try_GET(url, write_disk(tf))
  if (!is_response(resp_file)) {
    message(resp_file)
    return(invisible(NULL))
  }
  structure(tf, source = url, class = "access_url")
}

enclose <- function(x) {
  paste0("[", x, "]")
}

print.access_url <- function(x) {
  cat(enclose("Local file"), "\n\t", x, "\n")
  cat(enclose("Remote file"), "\n\t", attr(x, "source"))
}
