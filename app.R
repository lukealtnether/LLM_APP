required_packages <- c(
  "shiny", "jsonlite", "shinyjs", "jsonvalidate",
  "readxl", "writexl", "tidyverse", "ollamar",
  "httr2", "arsenal", "shinyBS", "ggvenn", "bslib"
)

# Function to install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Install and load packages
invisible(lapply(required_packages, function(pkg) {
  install_if_missing(pkg)
  library(pkg, character.only = TRUE)
}))

# source("r functions/LLM extract function.R")

#HOMEPAGE app
source("HOMEPAGE/ui.R")
source("HOMEPAGE/server.R")

# JSON app
source("JSON/ui.R")      
source("JSON/server.R")  

# EXAMPLES app
source("EXAMPLES/ui.R")      
source("EXAMPLES/server.R")  

# PROMPT ENGINEERING app
source("PROMPT_ENGINEERING/ui.R")
source("PROMPT_ENGINEERING/server.R")

# RANDOM SAMPLE app
source("RANDOM_SAMPLE/ui.R")
source("RANDOM_SAMPLE/server.R")

# LICENSE page
source("LICENSE/ui.R")
source("LICENSE/server.R")


# Define a Bootstrap 5 theme
app_theme <- bs_theme(
  version = 5,
  base_font = font_google("Fira Code"),
  bg = "#002B36",
  fg = "#EEE8D5",
  primary = "#2AA198",
  secondary = "#586e75"
)

ui <- navbarPage(
  title = "",
  theme = app_theme,   
  
  tags$head(
    tags$style(HTML("
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      
      .navbar {
        position: fixed;
        top: 0;
        width: 100%;
        z-index: 1000;
        margin-bottom: 0;
      }
      
      .tab-content {
        padding-top: 70px;
        height: calc(100vh - 70px);
        overflow-y: auto;
      }
      
      .tab-pane {
        height: 100%;
        padding: 15px;
      }
      
      .tab-pane img {
        max-width: 100%;
        height: auto;
        display: block;
        margin: 0 auto;
      }
      
      .tab-pane figure {
        text-align: center;
        margin: 20px 0;
      }
      
      .tab-pane figcaption {
        font-style: italic;
        margin-top: 8px;
      }
      
      /* Selectize input box styling - uses CSS variables from bs_theme */
      .selectize-input,
      .selectize-control.single .selectize-input {
        background: var(--bs-body-bg) !important;
        color: var(--bs-body-color) !important;
        border-color: var(--bs-secondary) !important;
      }
      
      .selectize-input.focus {
        border-color: var(--bs-primary) !important;
      }
      
      /* Selectize dropdown styling */
      .selectize-dropdown {
        background: var(--bs-body-bg) !important;
        color: var(--bs-body-color) !important;
        border-color: var(--bs-primary) !important;
      }
      
      /* Dropdown options */
      .selectize-dropdown .option {
        background: var(--bs-body-bg) !important;
        color: var(--bs-body-color) !important;
      }
      
      /* Hovered option */
      .selectize-dropdown .option:hover,
      .selectize-dropdown .active {
        background: var(--bs-primary) !important;
        color: var(--bs-body-bg) !important;
      }
      
    "))
  ),

  tabPanel("HOME", homepage_ui),
  tabPanel("Create Schema", json_ui),
  tabPanel("Enter Example", examples_ui),
  tabPanel("Engineer Prompt", prompt_ui),
  tabPanel("Create Database", random_ui),
  tabPanel("License", license_ui)
)

server <- function(input, output, session) {
  homepage_server(input, output, session)
  json_server(input, output, session)
  examples_server(input, output, session)
  prompt_server(input, output, session)
  random_server(input, output, session)
  license_server(input, output, session)
}

shinyApp(ui, server)