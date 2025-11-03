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


# Define a Bootstrap 5 theme with full customization options
app_theme <- bs_theme(
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
  
  # ------------------------------------------------------------------------------

  # === COLORS ===
  bg = "#001e24",        # Background color (main page background)
  fg = "#EEE8D5",        # Foreground color (default text color)
  primary = "#2AA198",   # Primary brand color (buttons, links, highlights)
  secondary = "#2AA198", # Secondary color (used for accent elements)
  success = "#859900",   # Used for success messages and green buttons
  info = "#268BD2",      # Used for informational messages or outlines
  warning = "#d98816",   # Used for warning alerts and badges
  danger = "#c92f2c",    # Used for errors, red buttons, or danger alerts

  # === NAVBAR ===
  "navbar-bg" = "#002b33",         # Navbar background color
  "navbar-fg" = "#EEE8D5",         # Navbar text/icon color
  "navbar-light-color" = "#EEE8D5",# Navbar link color (light mode)
  "navbar-dark-color" = "#EEE8D5", # Navbar link color (dark mode)
  "navbar-light-active-color" = "#2AA198",  # Active link color (light)
  "navbar-dark-active-color" = "#2AA198",   # Active link color (dark)

  # === INPUTS & FORMS ===
  "input-bg" = "#002b33",          # Input field background
  "input-color" = "#EEE8D5",       # Input text color
  "input-border-color" = "#2AA198",# Border around inputs
  "input-placeholder-color" = "#93A1A1",  # Placeholder text color
  "input-focus-border-color" = "#2AA198", # Border when focused
  "input-focus-box-shadow" = "0 0 0 0.2rem rgba(42,161,152,0.25)", # Glow when focused

  # === BUTTONS ===
  "btn-border-radius" = "0.4rem",     # Rounded corners on buttons
  "btn-padding-y" = "0.4rem",         # Vertical padding
  "btn-padding-x" = "0.9rem",         # Horizontal padding
  "btn-font-weight" = "500",          # Slightly bolder button text
  "btn-primary-bg" = "#2AA198",       # Primary button background
  "btn-primary-color" = "#002b33",    # Primary button text color
  "btn-hover-bg" = "#26978E",         # Button hover color

  # === CARDS, PANELS, AND CONTAINERS ===
  "card-bg" = "#002b33",             # Background of card components
  "card-border-color" = "#2AA198",   # Card outline/border color
  "card-color" = "#EEE8D5",          # Text color inside cards

  # === TOOLTIP ===
  "tooltip-bg" = "#586E75",          # Tooltip background color
  "tooltip-color" = "#FDF6E3",       # Tooltip text color

  # === TABLES ===
  "table-bg" = "#002b33",            # Table background
  "table-color" = "#EEE8D5",         # Table text
  "table-striped-bg" = "#073642",    # Alternating row color
  "table-hover-bg" = "#094C5F",      # Hover row color

  # # UTSW--------------------------------------------------------------------------
  # 
  # # === COLORS ===
  # bg = "#00355d",        # Background color (main page background)
  # fg = "#FFFFFF",        # Foreground color (default text color)
  # primary = "#009ee2",   # Primary brand color (buttons, links, highlights)
  # secondary = "#009ee2", # Secondary color (used for accent elements)
  # success = "#00ab4e",   # Used for success messages and green buttons
  # info = "#268BD2",      # Used for informational messages or outlines
  # warning = "#f26531",   # Used for warning alerts and badges
  # danger = "#e52334",    # Used for errors, red buttons, or danger alerts
  # 
  # # === NAVBAR ===
  # "navbar-bg" = "#004c97",         # Navbar background color
  # "navbar-fg" = "#FFFFFF",         # Navbar text/icon color
  # "navbar-light-color" = "#FFFFFF",# Navbar link color (light mode)
  # "navbar-dark-color" = "#FFFFFF", # Navbar link color (dark mode)
  # "navbar-light-active-color" = "#009ee2",  # Active link color (light)
  # "navbar-dark-active-color" = "#009ee2",   # Active link color (dark)
  # 
  # # === INPUTS & FORMS ===
  # "input-bg" = "#636466",          # Input field background
  # "input-color" = "#FFFFFF",       # Input text color
  # "input-border-color" = "#004c97",# Border around inputs
  # "input-placeholder-color" = "#009ee2",  # Placeholder text color
  # "input-focus-border-color" = "#009ee2", # Border when focused
  # "input-focus-box-shadow" = "0 0 0 0.2rem rgba(42,161,152,0.25)", # Glow when focused
  # 
  # # === BUTTONS ===
  # "btn-border-radius" = "0.4rem",     # Rounded corners on buttons
  # "btn-padding-y" = "0.4rem",         # Vertical padding
  # "btn-padding-x" = "0.9rem",         # Horizontal padding
  # "btn-font-weight" = "500",          # Slightly bolder button text
  # "btn-primary-bg" = "#2AA198",       # Primary button background
  # "btn-primary-color" = "#002b33",    # Primary button text color
  # "btn-hover-bg" = "#26978E",         # Button hover color
  # 
  # # === CARDS, PANELS, AND CONTAINERS ===
  # "card-bg" = "#002b33",             # Background of card components
  # "card-border-color" = "#2AA198",   # Card outline/border color
  # "card-color" = "#EEE8D5",          # Text color inside cards
  # 
  # # === TOOLTIP ===
  # "tooltip-bg" = "#586E75",          # Tooltip background color
  # "tooltip-color" = "#FDF6E3",       # Tooltip text color
  # 
  # # === TABLES ===
  # "table-bg" = "#002b33",            # Table background
  # "table-color" = "#EEE8D5",         # Table text
  # "table-striped-bg" = "#073642",    # Alternating row color
  # "table-hover-bg" = "#094C5F",      # Hover row color
  # 
  # ------------------------------------------------------------------------------
  
  # === BORDERS & SHADOWS ===
  "border-radius" = "0.5rem",        # General corner rounding
  "box-shadow" = "0 4px 10px rgba(0,0,0,0.3)", # Default element shadow
)
 



ui <- navbarPage(
  title = "",
  theme = app_theme,   
  
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
  
  
  
  /* === Selectize Inputs === */
  .selectize-input,
  .selectize-control.single .selectize-input {
    background-color: #002b33 !important;
    color: #EEE8D5 !important;
    border-color: #2AA198 !important;
  }

  .selectize-input.focus {
    border-color: #2AA198 !important;
    box-shadow: 0 0 0 0.2rem rgba(42,161,152,0.25) !important;
  }

  /* === Selectize Dropdown === */
  .selectize-dropdown,
  .selectize-dropdown-content {
    background-color: #002b33 !important;
    background: #002b33 !important;
    color: #EEE8D5 !important;
    border: 1px solid #2AA198 !important;
    opacity: 1 !important;
  }

  .selectize-dropdown .option {
    background-color: #002b33 !important;
    background: #002b33 !important;
    color: #EEE8D5 !important;
    opacity: 1 !important; 
    padding: 8px 12px;
  }

  .selectize-dropdown .option:hover,
  .selectize-dropdown .option.active {
    background-color: #2AA198 !important;
    background: #2AA198 !important;
    color: #002b33 !important;
    opacity: 1 !important; 
  }
  
  .selectize-dropdown .option.selected {
    background-color: #073642 !important;
    background: #073642 !important;
    color: #EEE8D5 !important;
  }
  
  /* === Selectize Dropdown Arrow === */
  .selectize-control.single .selectize-input:after {
    border-color: #EEE8D5 transparent transparent transparent !important;
    border-top-color: #EEE8D5 !important;
  }
  
  .selectize-control.single .selectize-input.dropdown-active:after {
    border-color: transparent transparent #EEE8D5 transparent !important;
    border-bottom-color: #EEE8D5 !important;
  }
  
  /* For when input is focused */
  .selectize-control.single .selectize-input.focus:after {
    border-top-color: #2AA198 !important;
  }
")),

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