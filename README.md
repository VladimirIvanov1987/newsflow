Markdown

---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

{r, include = FALSE} knitr::opts_chunk\$set( collapse = TRUE, comment = "#\>", fig.path = "man/figures/README-", out.width = "100%" ) \# newsflow 📰

<!-- badges: start -->

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<!-- badges: end -->

**newsflow** is a personal news aggregator built with R and Shiny.

The application allows you to consolidate news from your favorite RSS feeds (tech blogs, news portals, etc.) into a single, unified interface. No need to keep dozens of tabs open—browse headlines and summaries in one place with convenient filtering.

## ✨ Features

-   **🔍 RSS Aggregation:** Instantly fetch news from multiple sources.
-   **💾 Persistent Storage:** The app remembers your feed list between sessions (data is stored locally in your user directory).
-   **🛡 Robust Error Handling:** If a feed is down or a URL is broken, the app handles it gracefully without crashing.
-   **🏷 Source Filtering:** Easily filter the news stream to see items from a specific provider.
-   **🗑 Subscription Management:** Add or remove feeds via a user-friendly interface.
-   **🎨 Modern UI:** Clean and responsive design powered by `bslib`.

## 📦 Installation

You can install the development version from GitHub: r 📌 install.packages("devtools") devtools::installgithub("VladimirIvanov1987/newsflow")

## 🚀 Usage

Launch the application with a single command: r library(newsflow)

📌 Start the aggregatorrun_newsflow()

Your default browser will open with your personal news feed.

### Quick Start:

1.  Paste an RSS feed URL (e.g., `https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml` or `https://habr.com/ru/rss/best/`) into the input field.
2.  Click **"Add"**.
3.  Click **"Refresh"** to fetch the latest articles.
4.  To remove a feed, click the trash icon 🗑 in the sidebar.

## 🛠 Tech Stack

This package demonstrates modern R package development practices: \* **Shiny Modules:** Modular architecture for clean and maintainable code. \* **tidyRSS:** Robust XML/RSS parsing. \* **bslib:** Modern Bootstrap themes. \* **httr/xml2:** Networking and data handling. \* **testthat:** Unit testing coverage.

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.
