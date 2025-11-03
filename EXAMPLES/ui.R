examples_ui <- fluidPage(
  tags$style(HTML("
  #example_text {
    white-space: pre-wrap;
    word-wrap: break-word;
  }
    ")),
  useShinyjs(),
  titlePanel("Example Data Entry"),
  tags$hr(),
  fluidRow(
    # Left column
    column(
      width = 8,
      fluidRow(
        column(4, fileInput("schema_file", "Upload JSON Schema (.json/.txt)")),
        column(4, 
          tags$div(
            class = "form-label",
            tags$label("Upload Examples (.xlsx)"),
            tooltip(
              span(icon("circle-info", lib = "font-awesome")),
              "Input at least 20 representative examples as the xlsx file. Place examples in the first column of an excel file without column names (data in A1:An with n examples).",
              placement = "right"
            )
          ),
          fileInput("empty_examples", NULL)
        ),
        column(4, uiOutput("example_col_picker"))
      ),
      h4("Example Text"),
      verbatimTextOutput("example_text"),
      fluidRow(
        column(6, actionButton("previous_button", label = NULL, icon = icon("arrow-left"), style = "width: 100%;")),
        column(6, actionButton("next_button", label = NULL, icon = icon("arrow-right"), style = "width: 100%;"))
      ),
      textOutput("example_counter"),
      tags$hr(),
      textInput("filename_xlsx", "Enter file name (without extension):", value = ""),
      downloadButton("download_xlsx", "Download .xlsx", class = "btn btn-warning")
    ),
    
    # Right column
    column(
      width = 4,
      uiOutput("dynamic_form"),
      actionButton("add_row", "Add Row", class = "btn btn-success"),
      actionButton("remove_row", "Remove Last Row", class = "btn btn-danger"),
      tags$hr(),
      h4(
        tooltip(
          span("Preview ", icon("circle-info", lib = "font-awesome")),
          "Input and validation logic for the given example. To ensure that the accuracy calculations in the next step are valid, all responses must conform to the schema.",
          placement = "right"
        )
      ),
      verbatimTextOutput("data_output")
    )
  )
)