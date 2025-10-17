DATA_DIR <- "data"

# Download edit history for bots that 'uncurrent' articles
get_bot_contribs <- function(username) {
  bot <- wikkitidy::wiki_action_request() |>
    wikkitidy::query_list_pages(
      "usercontribs",
      ucuser = username,
      uclimit = "max",
      ucprop = "comment|ids|title|timestamp",
      ucnamespace = 0
    ) |>
    wikkitidy::retrieve_all() |>
    dplyr::filter(stringr::str_detect(comment, "current")) |>
    dplyr::mutate(
      timestamp = lubridate::as_datetime(timestamp),
      date = lubridate::as_date(timestamp)
    )
}

yapperbot <- get_bot_contribs("Yapperbot")
tedderbot <- get_bot_contribs("TedderBot")

combined <- dplyr::bind_rows(tedderbot, yapperbot) |>
  readr::write_csv(file.path(DATA_DIR, "bots.csv"))
