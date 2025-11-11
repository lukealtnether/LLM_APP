validation_ui <- fluidPage(
  tags$style(HTML("
  #example_validate {
    white-space: pre-wrap;
    word-wrap: break-word;
  }
    ")),
  useShinyjs(),
  titlePanel("Validate LLM Output"),
  tags$hr(),
  fluidRow(
    column(4,
      # File upload
      fluidRow(
        column(6, fileInput("reader_1_xlsx", "Upload Reader 1 (.xlsx)")),
        column(6, fileInput("reader_2_xlsx", "Upload Reader 2 (.xlsx)"))
      ),
      tags$div(
        class = "form-label",
        tags$label("ID Column"),
        tooltip(
          span(icon("circle-info", lib = "font-awesome")),
          "Only applicable form array schema. For analysis, within each example, objects must be compared by an id column. Objects will otherwise be compared by row order - which may differ from the ground truth vs LLM output.",
          placement = "right"
        )),
      selectInput("val_id", NULL, choices = "", selected = ""),
      fluidRow(
        column(6, actionButton("adjudicate_llm", "Adjudicate", class = "btn btn-success", style = "width: 100%;")),
        column(6, actionButton("validate_llm", "Validate", class = "btn btn-warning", style = "width: 100%;"))
      ),
      tags$hr(),
      # Differences Table
      h4(
        tooltip(
          span("Differences ", icon("circle-info", lib = "font-awesome")),
          "Differences between the two dataframes. Compared by id column if provided, else by row. Select the correct reader in the true column.",
          placement = "right"
        )),
      DTOutput("validation_differences"),
      br(),
      # Reader data previews
      h4("Reader 1"),
      tableOutput("reader_1_output"),
      h4("Reader 2"),
      tableOutput("reader_2_output"),
      tags$hr(),
      # Scoring Cutoffs
      h4("Scoring Cutoffs"),
      fluidRow(
        column(6, textInput("cut_off_acc", label = "Accuracy", value = "0.9")),
        column(6, textInput("cut_off_jaccard", label = "Jaccard", value = "0.9"))
      ),
      actionButton("score_llm", "Score", class = "btn btn-success", style = "width: 100%;")
    ),
    column(8,
      h4("Example"),
      verbatimTextOutput("example_validate"),
      fluidRow(
        column(6, actionButton("previous_validation", label = NULL, icon = icon("arrow-left"), style = "width: 100%;")),
        column(6, actionButton("next_validation", label = NULL, icon = icon("arrow-right"), style = "width: 100%;"))
      ),
      br(),
      h4(
        tooltip(
          span("Ground Truth ", icon("circle-info", lib = "font-awesome")),
          "Resulting ground trith after reader discrependcies are resolved. If needed, all columns are editable with the ability to add and remove rows.",
          placement = "right"
        )),
      DTOutput("validation_gt"),
      br(), 
      fluidRow(
        column(6, actionButton("add_row_val", "Add Row", class = "btn btn-success", style = "width: 100%;")),
        column(6, actionButton("remove_row_val", "Remove Row", class = "btn btn-danger", style = "width: 100%;"))
      )
    )
  ),
  tags$hr(),
  fluidRow(
    column(3,
      textInput("filename_ground_truth", "Enter file name (without extension):", value = ""),
      downloadButton("download_ground_truth", "Download Ground Truth", class = "btn btn-warning")
    ),
    column(3,
      textInput("filename_llm_validation", "Enter file name (without extension):", value = ""),
      downloadButton("download_llm_validation", "Download Validation", class = "btn btn-warning")
    )
  )
)