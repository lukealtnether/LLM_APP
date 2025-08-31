prompt_ui <-  fluidPage(
    useShinyjs(),
    titlePanel("Prompt Engineering"),
    
    tags$style(HTML("
      #example_check {
        white-space: pre-wrap;
        word-wrap: break-word;
        max-height: 400px;
        overflow-y: auto;
        border: 1px solid #ddd;
        padding: 8px;
        background-color: #f9f9f9;
        border-radius: 4px;
      }
    ")),
    
    tags$hr(),
    
    fluidRow(
      column(
        width = 6,
        fluidRow(
          column(6, fileInput(("json_file"), "Upload JSON Schema (.json)")),
          column(6, uiOutput("example_file_ui"))
        ),
        tags$hr(),
        fluidRow(
          column(4, textInput(("id_column"), label = list("ID Column",
            bsButton("id_info", label = "",
              icon = icon("info", lib = "font-awesome"),
              style = "default", size = "extra-small")
            ),
            value = "")),
          bsPopover("id_info", "More Information", 
            content = HTML(paste("Only applicable for <b>array</b> schema.",
              "For analysis, within each example, <b>objects</b> must be compared by an id column.",
              "<b>Objects</b> will otherwise be compared by row order- which may be different from the key to the llm output."
            )
            ),
            "right", trigger = "click",
            options = list(container = "body")
          ),
          column(4, textInput(("llm_context"), label = list("Context window",
            bsButton("context_info", label = "",
              icon = icon("info", lib = "font-awesome"),
              style = "default", size = "extra-small")
            ), value = "4000")),
          bsPopover("context_info", "More Information", 
            content = HTML(paste("Context window is the working memory of the LLM.",
              "Each query consists of a prompt + schema + example. A token is the smalled language unit the LLM understands. ",
              "An estimated token count is given based on prompt word count and longest example, with ~0.75 tokens/word. Context widows are commonly rounded to the thousands.",
              "Context windows that are too small will truncate the example/prompt. Context windows that are too large can lead to inneffecient LLM response times."
            )
            ),
            "right", trigger = "click",
            options = list(container = "body")
          ),
          column(2, uiOutput(("word_count_info")))
        ),
        fluidRow(
          column(3, textInput(("llm_address"), "IP Address", value = "172.18.227.86")),
          column(5, selectInput(("llm_model"), "Model", choices = c("Need to specify IP address first")))
        )
      ),
      
      column(
        width = 6,
        column(width = 4,
          h4("Overall Statistics"),
          tableOutput(("obs_acc"))),
        column(width = 8,
          h4("Variable Statistics"),
          tableOutput(("prop_acc"))
          )
      )
    ),
    
    tags$hr(),
    
    fluidRow(
      column(
        width = 4,
        h4("Prompt"),
        uiOutput(("dynamic_prompt_inputs")),
        actionButton(("submit_query"), "Submit", class = "btn btn-success")
      ),
      column(
        width = 5,
        h4("Example"),
        verbatimTextOutput(("example_check")),
        fluidRow(
          column(6, actionButton(("previous_button"), label = NULL, icon = icon("arrow-left"), style = "width: 100%;")),
          column(6, actionButton(("next_button"), label = NULL, icon = icon("arrow-right"), style = "width: 100%;"))
        )
      ),
      column(
        width = 3,
        h4("Differences"),
        tableOutput(("differences_df")),
        verbatimTextOutput(("omissssion_ex")),
        verbatimTextOutput(("hallucinations_ex")),
        h4("LLM Output"),
        tableOutput(("llm_output")),
        h4("Key"),
        tableOutput(("key_output"))
      )
    ),
    
    tags$hr(),
    
    textInput(("filename_prompt"), "Enter file name (without exteion):", value = ""),
    downloadButton(("download_prompt"), "Download prompt"),
  )

