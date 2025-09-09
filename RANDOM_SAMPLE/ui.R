random_ui <- fluidPage(
  useShinyjs(),
  titlePanel("Run a Sample or Entire Batch"),
  tags$hr(),
  fluidRow(
    column(6,
      fluidRow(
        column(6, fileInput("batch_json", "Upload Schema (.json)")),
        column(6, fileInput("batch_prompt", "Upload Prompt (.txt)"))
      ),
      fluidRow(
        column(6, fileInput("batch_xlsx", label = list("Upload Batch (.xlsx)",
          bsButton("batch_info", label = "",
            icon = icon("info", lib = "font-awesome"),
            style = "default", size = "extra-small")
          ))),
        column(6, selectInput("input_column", label = list("Input Column",
          bsButton("input_col_info", label = "",
            icon = icon("info", lib = "font-awesome"),
            style = "default", size = "extra-small")
          ), choices = c("Upload Batch first")))
      ),
      tags$hr(),
      fluidRow(
        column(4, textInput("batch_address", "BIOHPC node", value = "172.18.227.")),
        column(4, selectInput("batch_model", "Model", choices = c("Enter IP address first"))),
      ),
      fluidRow(
        column(4, textInput("sample_size", label = list("Sample Size",
          bsButton("sample_info", label = "",
            icon = icon("info", lib = "font-awesome"),
            style = "default", size = "extra-small")
          ))),
        column(4, textInput("batch_context", "Context Window", value = "4000")),
        column(4, uiOutput("batch_word_count")),
      ),
      actionButton("submit_batch", "Submit", class = "btn btn-success"),
      tags$hr(),
      textInput("filename_batch", "Enter file name (without extension):", value = ""),
      downloadButton("download_batch", "Download Run")
    ),
    column(6, 
      h4("Validation instructions"),
      uiOutput("validation_instructions")
    )
    
  )
  
)
