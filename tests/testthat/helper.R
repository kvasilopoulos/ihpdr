skip_if_http_error <- function() {
  remote_file <- "https://www.dallasfed.org/institute/houseprice#tab2"
  skip_if(httr::http_error(remote_file))
}
