#' Получить путь к файлу конфигурации
#'
#' @return Путь к файлу
#' @noRd
get_config_path <- function() {
  # tools::R_user_dir — это стандарт CRAN для хранения данных приложения
  config_dir <- tools::R_user_dir("newsflow", which = "config")

  # Если папки нет, создаем
  if (!dir.exists(config_dir)) {
    dir.create(config_dir, recursive = TRUE)
  }

  file.path(config_dir, "feeds.rds")
}

#' Сохранить список ссылок
#'
#' @param urls Вектор ссылок
#' @noRd
save_urls <- function(urls) {
  path <- get_config_path()
  saveRDS(urls, path)
}

#' Загрузить список ссылок
#'
#' @return Вектор ссылок или NULL
#' @noRd
load_urls <- function() {
  path <- get_config_path()
  if (file.exists(path)) {
    return(readRDS(path))
  } else {
    return(NULL) # Если файла нет, вернем NULL
  }
}
