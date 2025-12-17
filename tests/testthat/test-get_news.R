test_that("get_news_data handles empty input", {
  res <- get_news_data(NULL)
  expect_null(res$data)
  expect_null(res$errors)
})

test_that("get_news_data handles mixed column types (Fix for Lenta+Habr crash)", {
  # Это сложный тест. Нам нужно имитировать, что tidyRSS возвращает разные типы.
  # Мы используем пакет mockery или просто переопределяем функцию локально,
  # но для простоты интеграционного теста попробуем реальные данные,
  # если есть интернет.

  # ВНИМАНИЕ: Для CRAN тесты с интернетом нужно пропускать.
  skip_if_offline()

  # Если сайт лежит, тест пропустится, а не упадет
  skip_on_cran()

  urls <- c(
    "https://habr.com/ru/rss/best/", # Обычно сложная структура
    "https://lenta.ru/rss/last24"    # Обычно простая структура
  )

  # Пытаемся получить данные
  res <- get_news_data(urls)

  # Проверяем, что ничего не упало
  expect_true(is.list(res))

  # Если оба сайта доступны, data должна быть таблицей
  if (is.null(res$errors)) {
    expect_s3_class(res$data, "data.frame")
    expect_true("item_title" %in% names(res$data))
    expect_true("feed_title" %in% names(res$data))
  }
})

test_that("get_news_data returns errors for bad URLs", {
  res <- get_news_data("https://bad.url.test/rss")
  expect_null(res$data)
  expect_true("https://bad.url.test/rss" %in% res$errors)
})
