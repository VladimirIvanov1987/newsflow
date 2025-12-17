#' @title Get News Data
#' @description Fetches and aggregates news from multiple RSS URLs.
#' @param urls A character vector of RSS URLs.
#' @return A list containing `data` (tibble) and `errors` (character vector).
#' @importFrom tidyRSS tidyfeed
#' @importFrom dplyr bind_rows select mutate arrange desc any_of
#' @importFrom purrr map safely
#' @export
get_news_data <- function(urls) {
  if (length(urls) == 0) return(list(data = NULL, errors = NULL))

  safe_feed <- purrr::safely(tidyRSS::tidyfeed)

  results <- purrr::map(urls, safe_feed)

  feed_data <- list()
  errors <- c()

  # Колонки, которые мы хотим оставить
  cols_to_keep <- c("item_title", "item_link", "item_pub_date", "feed_title")

  for (i in seq_along(results)) {
    res <- results[[i]]
    if (is.null(res$error)) {
      df <- res$result

      # Проверяем наличие даты и СРАЗУ оставляем только нужные колонки,
      # чтобы избежать конфликтов типов в лишних полях (например, item_category)
      if ("item_pub_date" %in% names(df)) {
        # Используем any_of, чтобы не падать, если какой-то колонки вдруг нет
        df_clean <- dplyr::select(df, dplyr::any_of(cols_to_keep))
        feed_data[[i]] <- df_clean
      }
    } else {
      errors <- c(errors, urls[i])
    }
  }

  final_df <- NULL
  if (length(feed_data) > 0) {
    final_df <- dplyr::bind_rows(feed_data) |>
      dplyr::mutate(item_pub_date = as.POSIXct(item_pub_date)) |>
      dplyr::arrange(dplyr::desc(item_pub_date))
  }

  list(data = final_df, errors = errors)
}
