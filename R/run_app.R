#' @title Run the Newsflow Application
#' @description Launches the Shiny application for news aggregation.
#' @importFrom shiny shinyApp
#' @importFrom bslib bs_theme
#' @export
run_newsflow <- function() {
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5, bootswatch = "zephyr"),
    newsUI("app")
  )

  server <- function(input, output, session) {
    newsServer("app")
  }

  shiny::shinyApp(ui, server)
}
