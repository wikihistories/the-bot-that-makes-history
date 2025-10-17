DATA_DIR <- "data"

# Get data on Yellowdesk's policing of {{current}} and related templates
yellowdesk <- wikkitidy::wiki_action_request() |>
  wikkitidy::query_list_pages(
    "usercontribs",
    ucuser = "Yellowdesk",
    uclimit = "max",
    ucprop = "comment|ids|title|timestamp",
    ucnamespace = 0 # only edits to articles
  ) |>
  wikkitidy::retrieve_all() |>
  dplyr::filter(stringr::str_detect(comment, "current")) |>
  dplyr::mutate(
    timestamp = lubridate::as_datetime(timestamp),
    date = lubridate::as_date(timestamp)
  )

yellowdesk |>
  readr::write_csv(
    file.path(DATA_DIR, "yellowdesk.csv")
  )
