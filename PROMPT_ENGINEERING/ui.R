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
          column(
            4,
            selectInput(
              "id_column",
              label = list(
                "ID Column",
                bsButton(
                  "id_info",
                  label = "",
                  icon = icon("info", lib = "font-awesome"),
                  style = "default",
                  size = "extra-small"
                )
              ),
              choices = "",
              selected = ""
            ),
            bsPopover(
              "id_info", "More Information", 
              content = HTML(paste(
                "Only applicable for <b>array</b> schema.",
                "For analysis, within each example, <b>objects</b> must be compared by an id column.",
                "<b>Objects</b> will otherwise be compared by row order - which may differ from the ground truth vs LLM output."
              )),
              "right", trigger = "click",
              options = list(container = "body")
            )
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
        column(width = 6,
          h4(list("Overall Statistics",
            bsButton("o_stat_info", label = "",
              icon = icon("info", lib = "font-awesome"),
              style = "default", size = "extra-small")
            )),
          tableOutput(("obs_acc"))),
        column(width = 6,
          h4(list("Variable Statistics",
            bsButton("v_stat_info", label = "",
              icon = icon("info", lib = "font-awesome"),
              style = "default", size = "extra-small")
            )),
          tableOutput(("prop_acc")),
          bsPopover("o_stat_info", "More Information", 
            content = HTML(paste("Context window is the working memory of the LLM.",
              "Basic overall statics evaulating the prompt. <b>Objects</b> refer to schema bjects and can be through of rows in the database. ",
              "<b>Halucinated</b> objects, refer to objects in the LLM response not present in the ground truth. <b>Omissions</b> are the opposite.",
              "<b>Accuracy</b> is defined by the formula (TP + TN) / (TP + TN + FP + FN) and is a good representation of how well the prompt is doing",
              "from a completely balanced perspective (this is the only metric that rewards true negatives). <b>F1 Score</b> is defined by the formula 2TP / (2TP + FP +FN) and represents",
              "the harmonic mean of precision and recall. F1 is a good metric for classification tasks where you want to identify prositive finidngs (ie: PE identification algoritm).",
              "Of note, for all of these fomulas",
              "hallucinations count as a FP in every property and omissions count as a FN in every property. However, for the variable metrics to the right, only shared objects are", 
              "factored to truly asses each property."
              
            )
            ),
            "right", trigger = "click",
            options = list(container = "body")
          ),
          bsPopover("v_stat_info", "More Information", 
            content = HTML(paste("Stats are given for each object property. Formulas are the same as for the total statistics. However,",
              "only shared objects are factored to give a better representation of each property decription."
            )
            ),
            "right", trigger = "click",
            options = list(container = "body")
          ),
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
        h4("Ground Truth"),
        tableOutput(("key_output"))
      )
    ),
    
    tags$hr(),
    
    textInput(("filename_prompt"), "Enter file name (without exteion):", value = ""),
    downloadButton(("download_prompt"), "Download prompt"),
  )

