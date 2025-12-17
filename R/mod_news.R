#' @title News Module UI
#' @description UI for the news feed module
#' @param id Module ID
#' @importFrom shiny NS tagList h1 sidebarLayout sidebarPanel mainPanel textInput actionButton hr uiOutput selectInput showNotification h4 p div h5 strong a span icon showModal modalDialog checkboxGroupInput modalButton removeModal
#' @export
newsUI <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(

    shiny::div(
      style = "padding: 10px 15px; border-bottom: 1px solid #eee; margin-bottom: 20px;",
      shiny::h1("NewsFlow \U0001F4F0", style = "font-size: 2rem; margin: 0; color: #2c3e50;")
    ),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        width = 3,
        shiny::h4("Controls"),
        shiny::textInput(ns("url_input"), "Add RSS Feed", placeholder = "https://..."),
        shiny::actionButton(ns("add_btn"), "Add", icon = shiny::icon("plus"), class = "btn-success"),
        shiny::hr(),

        shiny::h5("Filter Sources"),
        shiny::selectInput(ns("source_filter"), NULL, choices = "All", selected = "All", multiple = TRUE),

        shiny::hr(),
        shiny::div(
          style = "display: flex; justify-content: space-between; align-items: center;",
          shiny::p("Saved Feeds:", style = "margin-bottom: 0; font-weight: bold;"),
          shiny::actionButton(ns("del_mode_btn"), "", icon = shiny::icon("trash"), class = "btn-outline-danger btn-sm", title = "Remove feeds")
        ),
        shiny::uiOutput(ns("feed_list")),

        shiny::hr(),
        shiny::actionButton(ns("refresh_btn"), "Refresh", icon = shiny::icon("sync"), class = "btn-primary", width = "100%")
      ),
      shiny::mainPanel(
        width = 9,
        shiny::uiOutput(ns("status_header")),
        shiny::uiOutput(ns("news_results"))
      )
    )
  )
}

#' @title News Module Server
#' @description Server logic for the news feed module
#' @param id Module ID
#' @importFrom shiny moduleServer reactiveVal observeEvent renderUI HTML req updateSelectInput showNotification icon showModal modalDialog checkboxGroupInput modalButton removeModal
#' @importFrom purrr map
#' @export
newsServer <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # --- 1. Init ---
    saved_urls <- load_urls()
    initial_urls <- if (is.null(saved_urls)) c("https://habr.com/ru/rss/best/") else saved_urls

    urls <- shiny::reactiveVal(initial_urls)
    news_data <- shiny::reactiveVal(NULL)

    # --- 2. Add URL ---
    shiny::observeEvent(input$add_btn, {
      shiny::req(input$url_input)
      current_list <- urls()
      new_url <- input$url_input

      if (!new_url %in% current_list) {
        new_list <- c(current_list, new_url)
        urls(new_list)
        save_urls(new_list)
        shiny::showNotification("Feed added successfully.", type = "message")
      }
    })

    # --- Remove Logic ---
    shiny::observeEvent(input$del_mode_btn, {
      current_list <- urls()
      if (length(current_list) == 0) {
        shiny::showNotification("List is empty.", type = "warning")
        return()
      }

      shiny::showModal(shiny::modalDialog(
        title = "Manage Feeds",
        shiny::checkboxGroupInput(ns("urls_to_delete"), "Select feeds to remove:", choices = current_list),
        footer = shiny::tagList(
          shiny::modalButton("Cancel"),
          shiny::actionButton(ns("confirm_delete_btn"), "Remove Selected", class = "btn-danger")
        ),
        easyClose = TRUE
      ))
    })

    shiny::observeEvent(input$confirm_delete_btn, {
      to_remove <- input$urls_to_delete
      if (is.null(to_remove)) {
        shiny::removeModal()
        return()
      }

      old_list <- urls()
      new_list <- setdiff(old_list, to_remove)
      urls(new_list)
      save_urls(new_list)

      shiny::removeModal()
      shiny::showNotification("Feeds removed.", type = "message")
    })

    output$feed_list <- shiny::renderUI({
      shiny::tagList(purrr::map(urls(), function(x) shiny::div(style="font-size: 0.75em; color: #666; overflow: hidden; white-space: nowrap; margin-bottom: 2px;", x)))
    })

    # --- 3. Load Data ---
    shiny::observeEvent(list(input$refresh_btn, urls()), {
      if (length(urls()) == 0) {
        news_data(NULL)
        shiny::updateSelectInput(session, "source_filter", choices = character(0))
        return()
      }

      id_load <- shiny::showNotification("Loading news...", duration = NULL, closeButton = FALSE)
      on.exit(shiny::removeNotification(id_load), add = TRUE)

      res <- get_news_data(urls())
      news_data(res$data)

      if (!is.null(res$errors)) {
        msg <- paste("Failed to load:", paste(res$errors, collapse = ", "))
        shiny::showNotification(msg, type = "error", duration = 10)
      }

      if (!is.null(res$data)) {
        sources <- unique(res$data$feed_title)
        shiny::updateSelectInput(session, "source_filter", choices = sources, selected = sources)
      }
    }, ignoreInit = FALSE)

    # --- 4. Render ---
    filtered_data <- shiny::reactive({
      df <- news_data()
      if (is.null(df)) return(NULL)
      if (!is.null(input$source_filter)) {
        df <- df[df$feed_title %in% input$source_filter, ]
      }
      return(df)
    })

    output$status_header <- shiny::renderUI({
      count <- if (is.null(filtered_data())) 0 else nrow(filtered_data())
      shiny::h4(paste("News Feed (", count, "items)"))
    })

    output$news_results <- shiny::renderUI({
      df <- filtered_data()
      if (is.null(df) || nrow(df) == 0) {
        msg <- if (length(urls()) == 0) "Source list is empty. Add an RSS feed." else "No news to display."
        return(shiny::div(style="color: gray; margin-top: 20px;", msg))
      }

      cards <- lapply(1:nrow(df), function(i) {
        row <- df[i, ]
        shiny::div(
          class = "card mb-3",
          style = "padding: 15px; margin-bottom: 15px; border-left: 5px solid #007bc2; box-shadow: 2px 2px 5px rgba(0,0,0,0.1); background: white;",
          shiny::h5(style = "margin-bottom: 10px;", shiny::a(href = row$item_link, target = "_blank", style="text-decoration: none; color: #333; font-weight: bold;", row$item_title)),
          shiny::div(style = "display: flex; justify-content: space-between; align-items: center; font-size: 0.85em; color: #666;",
                     shiny::span(class = "badge bg-secondary", style = "background-color: #6c757d; color: white; padding: 5px 10px; border-radius: 10px;", row$feed_title),
                     shiny::span(format(row$item_pub_date, "%d %b %H:%M"))
          )
        )
      })
      shiny::tagList(cards)
    })
  })
}
