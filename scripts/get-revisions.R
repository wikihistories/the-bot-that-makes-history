DATA_DIR <- "data"
MIN_REMOVALS <- 3

data <-  dplyr::bind_rows(
  readr::read_csv(file.path(DATA_DIR, "bots.csv")),
  readr::read_csv(file.path(DATA_DIR, "yellowdesk.csv"))
)

key_pages <- data |>
  dplyr::group_by(user, pageid) |>
  dplyr::count() |>
  dplyr::filter(n > MIN_REMOVALS)

get_all_revisions <- function(pageid) {
  req <- wikkitidy::wiki_action_request() |>
    wikkitidy::query_by_pageid(pageid) |>
    wikkitidy::query_page_properties(
      property = "revisions",
      rvlimit = 50,
      rvprop = "content"
    )

  revisions <- wikkitidy::retrieve_all(req)

  # Save them!
  readr::write_rds(revisions, file.path(DATA_DIR, paste0("revisions-pageid-", pageid, ".rds")))

  return(revisions)
}

# To get multiple revisions... you need to do it one page at a time...
# The below just gets the latest revision

revisions <- key_pages |>
  dplyr::pull(pageid) |>
  purrr::map(get_all_revisions, .progress = "Fetching revisions") |>
  dplyr::bind_rows()
