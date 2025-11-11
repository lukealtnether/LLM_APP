required_packages <- c(
  "shiny", "jsonlite", "shinyjs", "jsonvalidate",
  "readxl", "writexl", "tidyverse", "ollamar",
  "httr2", "arsenal", "shinyBS", "ggvenn", "bslib", "DT"
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

# VALIDATION app
source("VALIDATION/ui.R")
source("VALIDATION/server.R")

# LICENSE page
source("LICENSE/ui.R")
source("LICENSE/server.R")

options(bslib.cache = FALSE)

# Define a Bootstrap 5 theme with full customization options
dark_app_theme <- bs_theme(
  version = 5,                           # Bootstrap version (4 or 5)
  
  # === TYPOGRAPHY ===
  base_font = font_google("Fira Code"),  # Primary font used for all body text

  # === FONT SIZES ===
  "font-size-base" = "0.875rem",           # Base font size (affects most text)
  "label-font-size" = "0.875rem",      # Input label size (this is the one!)
  "form-label-font-size" = "0.875rem", # Alternative for form labels
  "input-font-size" = "0.875rem",          # Text inside the input field itself
  "code-font-size" = "0.875rem",

  # Heading sizes
  "h1-font-size" = "2.5rem",
  "h2-font-size" = "2rem",
  "h3-font-size" = "1.5rem",
  "h4-font-size" = "1.25rem",
  "h5-font-size" = "1rem",
  "h6-font-size" = ".77rem",


  # --------------------------------------------------------------------------

  # === COLORS ===
  bg = "#00141c",        # Background color (main page background)
  fg = "#FFFFFF",        # Foreground color (default text color)
  primary = "#009ee2",   # Primary brand color (buttons, links, highlights)
  secondary = "#818181", # Secondary color (used for accent elements)
  success = "#00ab4e",   # Used for success messages and green buttons
  info = "#268BD2",      # Used for informational messages or outlines
  warning = "#009ee2",   # Used for warning alerts and badges
  danger = "#e52334",    # Used for errors, red buttons, or danger alerts

  # === NAVBAR ===
  "navbar-bg" = "#000d12",         # Navbar background color
  "navbar-fg" = "#FFFFFF",         # Navbar text/icon color
  "navbar-light-color" = "#FFFFFF",# Navbar link color (light mode)
  "navbar-dark-color" = "#FFFFFF", # Navbar link color (dark mode)
  "navbar-light-active-color" = "#009ee2",  # Active link color (light)
  "navbar-dark-active-color" = "#009ee2",   # Active link color (dark)

  # === INPUTS & FORMS ===
  "input-bg" = "#0E1D24",          # Input field background
  "input-color" = "#FFFFFF",       # Input text color
  "input-border-color" = "#818181",# Border around inputs
  "input-placeholder-color" = "#818181",  # Placeholder text color
  "input-focus-border-color" = "#818181", # Border when focused
  "input-focus-box-shadow" = "0 0 0 0.2rem rgba(42,161,152,0.25)", # Glow when focused
  
  # === TABLES ===
  "table-bg" = "#0E1D24",            # Table background
  "table-color" = "#FFFFFF",         # Table text

  # ------------------------------------------------------------------------------
  
  # === BORDERS & SHADOWS ===
  "border-radius" = "0.5rem",        # General corner rounding
  "box-shadow" = "0 4px 10px rgba(0,0,0,0.3)", # Default element shadow
)
 



ui <- navbarPage(
  title = "",
  theme = dark_app_theme,
  
  
  tags$style(HTML("
  /* === Selectize Inputs === */
  .selectize-input,
  .selectize-control.single .selectize-input {
    background-color: #0E1D24 !important;
    color: #FFFFFF !important;
    border-color: #818181 !important;
  }
  
  
  /* === Selectize Dropdown === */
    .selectize-dropdown,
  .selectize-dropdown-content {
    background-color: #0E1D24 !important;
      background: #0E1D24 !important;
      color: #FFFFFF !important;
      border: 1px solid #818181 !important;
    opacity: 1 !important;
  }
  
  .selectize-dropdown .option {
    background-color: #0E1D24 !important;
      background: #0E1D24 !important;
      color: #FFFFFF !important;
      opacity: 1 !important; 
    padding: 8px 12px;
  }
  
  .selectize-dropdown .option:hover,
  .selectize-dropdown .option.active {
    background-color: #818181 !important;
      background: #818181 !important;
      color: #0E1D24 !important;
      opacity: 1 !important; 
  }
  
  .selectize-dropdown .option.selected {
    background-color: ##00141 !important;
      background: #00141 !important;
      color: #FFFFFF !important;
  }
  
  /* === Selectize Dropdown Arrow === */
    .selectize-control.single .selectize-input:after {
      border-color: #FFFFFF transparent transparent transparent !important;
        border-top-color: #FFFFFF !important;
    }
  
  .selectize-control.single .selectize-input.dropdown-active:after {
    border-color: transparent transparent #FFFFFF transparent !important;
    border-bottom-color: #FFFFFF !important;
  }
  
  /* For when input is focused */
    .selectize-control.single .selectize-input.focus:after {
      border-top-color: #818181 !important;
    }
  
  /* === Dark theme fix for DT tables === */
    table.dataTable {
      background-color: #0E1D24 !important;   /* match card-bg */
        color: #FFFFFF !important;              /* match text color */
        border-color: #818181 !important;       /* match border */
    }
  
  table.dataTable tbody tr {
    background-color: #0E1D24 !important;
  }
  
  table.dataTable tbody tr:hover {
    background-color: #00141c !important;   /* match table-hover-bg */
  }
  
  table.dataTable thead th {
    border-bottom: 1px solid #FFFFFF !important;
  }
  table.dataTable tbody td, 
  table.dataTable tbody th {
    border: none !important;
  }
  
  .dataTables_wrapper .dataTables_length,
  .dataTables_wrapper .dataTables_filter,
  .dataTables_wrapper .dataTables_info,
  .dataTables_wrapper .dataTables_paginate {
    color: #FFFFFF !important;
  }
  
  .dataTables_wrapper .dataTables_paginate .paginate_button {
    color: #FFFFFF !important;
      background-color: #0E1D24 !important;
      border: 1px solid #818181 !important;
  }
  
  .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    color: #0E1D24 !important;
      background-color: #818181 !important;
      
      
      ")),
  
  tabPanel("HOME", homepage_ui),
  tabPanel("Create Schema", json_ui),
  tabPanel("Enter Example", examples_ui),
  tabPanel("Engineer Prompt", prompt_ui),
  tabPanel("Create Database", random_ui),
  tabPanel("Validate Sample", validation_ui),
  tabPanel("License", license_ui)
)

server <- function(input, output, session) {
  homepage_server(input, output, session)
  json_server(input, output, session)
  examples_server(input, output, session)
  prompt_server(input, output, session)
  random_server(input, output, session)
  validation_server(input, output, session)
  license_server(input, output, session)
}

shinyApp(ui, server)