prompt_server <- function(input, output, session) {
  nested_colnames <- reactiveVal(NULL)
  nested_coltypes <- reactiveVal()
  rv <- reactiveValues(test = NULL, df = NULL, venn_plot = NULL)
  
  output$example_file_ui <- renderUI({
    fileInput(("example_file"), "Upload Completed Examples (.xlsx)")
  })
  
  observeEvent(input$example_file, {
    req(input$example_file)
    example_excel <- read_excel(input$example_file$datapath, col_names = TRUE)
    df <- example_excel %>%
      select(examples, ends_with("_app")) %>%
      rename_with(~ sub("_app$", "", .x), ends_with("_app")) %>%
      nest(data = -examples)
    rv$df <- df  
    first_nested <- df$data[[1]]
    nested_colnames(names(first_nested))
  })
  
  observe({
    updateSelectInput(
      session,
      "id_column",
      choices = c("None" = "", nested_colnames()),
      selected = ""
    )
  })
  
  get_ollama_models <- function(ip) {
    url <- paste0("http://", ip, ":11434/api/tags")
    res <- try(httr::GET(url), silent = TRUE)
    if (inherits(res, "try-error") || httr::status_code(res) != 200) {
      return(NULL)
    }
    parsed <- jsonlite::fromJSON(httr::content(res, as = "text", encoding = "UTF-8"))
    model_names <- parsed$models$name
    return(model_names)
  }
  
  observeEvent(input$llm_address, {
    models <- get_ollama_models(input$llm_address)
    if (is.null(models)) {
      updateSelectInput(session, "llm_model", choices = c("Connection failed"))
    } else {
      updateSelectInput(session, "llm_model", choices = models, selected = models[1])
    }
  })
  
  output$dynamic_prompt_inputs <- renderUI({
    cols <- nested_colnames()
    if (is.null(cols)) return(NULL)
    tagList(
      textAreaInput("general_info", "General Information", rows = 3, width = "100%"),
      lapply(cols, function(colname) {
        textAreaInput(inputId = paste0("col_", colname), label = colname, rows = 2, width = "100%")
      })
    )
  })
  
  collapsed_prompt <- reactive({
    req(nested_colnames())
    prompt_texts <- c()
    if (!is.null(input$general_info) && nzchar(trimws(input$general_info))) {
      prompt_texts <- c(prompt_texts, paste0("General Information: ", input$general_info))
    }
    for (colname in nested_colnames()) {
      val <- input[[paste0("col_", colname)]]
      if (!is.null(val) && nzchar(trimws(val))) {
        prompt_texts <- c(prompt_texts, paste0(colname, ": ", val))
      }
    }
    paste(prompt_texts, collapse = "\n\n")
  })
  
  estimate_tokens <- function(text) {
    words <- strsplit(text, "\\s+")[[1]]
    word_count <- length(words)
    token_estimate <- ceiling(word_count / 0.75)
    list(words = word_count, tokens = token_estimate)
  }
  
  output$word_count_info <- renderUI({
    req(collapsed_prompt())
    prompt_stats <- estimate_tokens(collapsed_prompt())
    example_stats <- list(words = 0, tokens = 0)
    longest_example <- ""
    if (!is.null(rv$df)) {
      if ("examples" %in% names(rv$df)) {
        word_counts <- sapply(rv$df$examples, function(x) length(strsplit(x, "\\s+")[[1]]))
        idx_longest <- which.max(word_counts)
        longest_example <- rv$df$examples[idx_longest]
        example_stats <- estimate_tokens(longest_example)
      }
    }
    combined_tokens <- prompt_stats$tokens + example_stats$tokens
    tagList(tags$b("Estimated Tokens:"), sprintf(" %d", combined_tokens))
  })
  
  observeEvent(input$submit_query, {
    req(input$example_file, input$json_file, nested_colnames())
    test <- rv$df
    schema_r <- jsonlite::fromJSON(input$json_file$datapath, simplifyVector = FALSE)
    
    prompt_texts <- c()
    if (!is.null(input$general_info) && nzchar(trimws(input$general_info))) {
      prompt_texts <- c(prompt_texts, paste0("General Information: ", input$general_info))
    }
    for (colname in nested_colnames()) {
      val <- input[[paste0("col_", colname)]]
      if (!is.null(val) && nzchar(trimws(val))) {
        prompt_texts <- c(prompt_texts, paste0(colname, ": ", val))
      }
    }
    full_prompt <- paste(prompt_texts, collapse = "\n\n")
    
    input_text_column <- "examples"
    output_column <- input$llm_model
    seed_num <- 1234
    
    empty_nested <- as.data.frame(setNames(rep(list(character()), length(nested_colnames())), nested_colnames()))
    test[[output_column]] <- replicate(nrow(test), empty_nested[0, ], simplify = FALSE)
    test[[paste0(output_column, "_time")]] <- numeric(nrow(test))
    
    messages_list <- list(list(role = "system", content = full_prompt))
    total <- nrow(test)
    
    withProgress(message = "Running model inference...", value = 0, {
      for (i in seq_len(total)) {
        incProgress(1 / total, detail = paste0("Running row ", i, " of ", total))
        start_time <- Sys.time()
        
        result <- tryCatch({
          chat(
            host = paste0("http://", input$llm_address, ":11434"),
            model = input$llm_model,
            message = create_messages(
              messages_list,
              list(content = test[[input_text_column]][i], role = "user")
            ),
            format = schema_r,
            output = "text",
            temperature = 0,
            seed = seed_num,
            num_ctx = as.numeric(input$llm_context)
          )
        }, error = function(e) {
          message("Error in row ", i, ": ", conditionMessage(e))
          return(NULL)
        })
        
        end_time <- Sys.time()
        duration <- as.numeric(difftime(end_time, start_time, units = "s"))
        
        if (!is.null(result)) {
          parsed <- tryCatch(fromJSON(result), error = function(e) NULL)
          if (!is.null(parsed$data)) {
            test[[output_column]][i] <- list(parsed$data%>%
                                               modify_if(is.null, ~NA) %>%
                                               as.data.frame(stringsAsFactors = FALSE))
          }
        }
        
        test[[paste0(output_column, "_time")]][i] <- duration
      }
    })
    
    #convert any empty lists to dataframes
    test[[output_column]] <- map(test[[output_column]], function(x) {
      if (is.data.frame(x) && nrow(x) > 0) {
        x
      } else {
        # Create a 1-row NA-filled data frame with correct column names
        as.data.frame(
          setNames(
            replicate(length(nested_colnames()), NA, simplify = FALSE),
            nested_colnames()
          )
        )
      }
    })
    
    #make data types the same by unnesting and renesting
    llm_fixed <- test %>%
      select(examples, all_of(output_column)) %>%
      unnest(cols = all_of(output_column)) %>%
      group_by(examples) %>%
      nest(!!sym(output_column) := -examples) %>%
      ungroup()
    
    # Merge fixed LLM output back into the original test
    test <- test %>%
      select(-all_of(output_column)) %>%
      left_join(llm_fixed, by = "examples")
    
    
    # Accuracy analysis
    llm_model <- input$llm_model
    id_column <- input$id_column
    by_vars <- c("examples")
    if (nzchar(id_column)) by_vars <- c(by_vars, id_column)
    
    llm_run_filtered <- test %>%
      select(examples, all_of(llm_model)) %>%
      unnest(cols = all_of(llm_model))
    
    key_filtered <- test %>% 
      select(examples, data) %>% 
      unnest(cols = data)
    
    llm_output <- llm_run_filtered %>%
      select(-all_of(by_vars))
    # ------------------------------------------------------------------------------
    
    comparison <- comparedf(llm_run_filtered, key_filtered, by = by_vars, int.as.num = TRUE)
    
    
    #get a df of the true hallucinations/omission by filtering out non objects
    hallucinations_df <- comparison$frame.summary$unique[[1]] %>%
      filter(!if_any(-observation, is.na))
    
    omissions_df <- comparison$frame.summary$unique[[2]] %>%
      filter(!if_any(-observation, is.na))
    
    #df of differences by each variable
    total_differences <- diffs(comparison, by.var = TRUE) %>%
      select(-var.x, -NAs) %>%
      rename(variable = var.y) 
    
    #df of differences by values
    diff_details <- diffs(comparison) 
   
    # ------------------------------------------------------------------------------
    # new differences logic
    
    diff_merge <- diff_details %>%
      select( by_vars, var.x, values.x, values.y) %>%
      rename("Variable" = var.x,
        "LLM" = values.x,
        "Ground Truth"= values.y) %>%
      nest(diff = any_of(c(id_column, "Variable", "LLM", "Ground Truth")))
    
    hal_id <- hallucinations_df %>%
      select(!any_of(c("observation", id_column))) %>%
      mutate(H = 1)
    
    omi_id <- omissions_df %>%
      select(!any_of(c("observation", id_column))) %>%
      mutate(O = 1)
    
    test <- left_join(test, diff_merge, by = input_text_column)
    test <- left_join(test, hal_id, by = input_text_column) %>%
      mutate(H = if_else(is.na(H), 0, H))
    test <- left_join(test, omi_id, by = input_text_column) %>%
      mutate(O = if_else(is.na(O), 0, O))
    
    # ------------------------------------------------------------------------------
    
  
    #summary of fp and fn based on na in the diff details
    fp_fn_summary <- diff_details %>%
      mutate(
        JA = ifelse(!is.na(values.x), 1, 0),
        JB = ifelse(!is.na(values.y), 1, 0)
      ) %>%
      group_by(var.x) %>%
      summarise(
        JA = sum(JA),
        JB = sum(JB),
        .groups = "drop"
      )
    
    #Get the unique rows in the LLM and filter them out to get the compared df
    unique_rows <- comparison$frame.summary$unique[[1]]$observation
    
    shared_df <- llm_run_filtered %>%
      slice(-unique_rows) %>%
      pivot_longer(
        cols = -all_of(by_vars),
        names_to = "var.x",
        values_to = "values.x",
        values_transform = list(values.x = as.character)
      )
    
    #get the wrong values and rows 
    wrong_obs <- diff_details %>%
      select(by_vars, var.x)
    
    #Get the unique rows in the LLM and filter them out to get the compared df
    unique_rows <- comparison$frame.summary$unique[[1]]$observation
   
    shared_df <- llm_run_filtered %>%
      { 
        if(length(unique_rows) == 0) . else slice(., -unique_rows)
      } %>%
      pivot_longer(
        cols = -all_of(by_vars),
        names_to = "var.x",
        values_to = "values.x",
        values_transform = list(values.x = as.character)
      )
    
    #now remove the incorrect values to only get the correct answers from the LLM
    correct_shared_df <- shared_df %>%
      anti_join(wrong_obs, by = c(by_vars, "var.x"))
    
    #from these values, get tp and tn from na
    tp_tn_summary <- correct_shared_df %>%
      mutate(
        TN = ifelse(is.na(values.x), 1, 0),
        TP = ifelse(!is.na(values.x), 1, 0)
      ) %>%
      group_by(var.x) %>%
      summarise(
        TP = sum(TP),
        TN = sum(TN),
        .groups = "drop"
      )

    # Merge into total_differences
    total_differences <- total_differences %>%
      mutate(Errors = as.integer(n)) %>%
      left_join(fp_fn_summary, by = c("variable" = "var.x")) %>%
      left_join(tp_tn_summary, by = c("variable" = "var.x")) %>%
      rename(Variable = variable) %>%
      mutate(across(c(TP, TN, JA, JB), ~ ifelse(is.na(.), 0, .))) %>%
      mutate(Accuracy = paste0(round(100*((TP + TN) / (comparison$frame.summary$n.shared[1])), 2),"%")) %>%
      mutate(Jaccard = round((TP/(TP + JA + JB)), 2)) %>%
      select(TP, TN, JA, JB, -n)
    
    llm_obs <- llm_run_filtered %>%
      filter(!if_any(all_of(by_vars), is.na)) %>%
      nrow()
    
    key_obs <- key_filtered %>%
      filter(!if_any(all_of(by_vars), is.na)) %>%
      nrow()

   
    # Exclude first and average time
    time_col <- paste0(input$llm_model, "_time")
    avg_time <- paste0(round(mean(test[[time_col]][-1], na.rm = TRUE), 2), "s")
    
    #get overall statistics
    hallucinations <- nrow(hallucinations_df)
    omissions <- nrow(omissions_df)
    shared_obs <- comparison$frame.summary$n.shared[1]
    total_tp <- sum(tp_tn_summary$TP)
    total_tn <- sum(tp_tn_summary$TN)
    total_ja <- (sum(fp_fn_summary$JA) + omissions*nrow(total_differences))
    total_jb <- (sum(fp_fn_summary$JB) + hallucinations*nrow(total_differences))
    total_accuracy <- paste0(round((100*(total_tp + total_tn) / (nrow(llm_output)*ncol(llm_output))), 2),"%")
    total_jaccard <- round((total_tp/(total_tp + total_ja + total_jb)), 2)
    
    venn_list <- list(
      "Ground Truth" = 1:(total_tp + total_ja),  
      "LLM" = (total_ja + 1):(total_ja + total_tp + total_jb)  
    )
    
    # Create the Venn diagram
    rv$venn_plot <- ggvenn(venn_list, 
      fill_color = c("blue", "red"),
      fill_alpha = 0.5,
      stroke_size = 1,
      set_name_size = 6,
      text_size = 8,
      show_percentage = FALSE,
      auto_scale = TRUE)
  

    #display tables
    rv$summary_table <- data.frame(
      Metric = c("Average Time", "LLM objects", "True objects", "Hallucinated objects", "Omitted objects", "Compared objects",
        "Accuracy", "Jaccard Similarity"
        ),
      Value = as.character(c(avg_time, llm_obs, key_obs, hallucinations, omissions, shared_obs,
        total_accuracy, total_jaccard
        )),
      stringsAsFactors = FALSE
    )
    rv$variable_summary <- total_differences
    rv$test <- test
    
  })
  
  # -----------Analysis
  example_index <- reactiveVal(1)
  
  observeEvent(input$next_button, {
    req(rv$test)
    current <- example_index()
    if (current < nrow(rv$test)) example_index(current + 1)
  })
  
  observeEvent(input$previous_button, {
    req(rv$test)
    current <- example_index()
    if (current > 1) example_index(current - 1)
  })
  
  current_row <- reactive({
    req(test())
    test()[example_index(), ]
  })
  
  output$download_prompt <- downloadHandler(
    filename = function() {
      fname <- input$filename_prompt
      if (is.null(fname) || fname == "") {
        fname <- "prompt"
      }
      paste0(fname, ".txt")
    },
    content = function(file) {
      writeLines(collapsed_prompt(), file)
    })
  
  output$obs_acc <- renderTable({
    req(rv$summary_table)
    rv$summary_table
  }, rownames = FALSE, striped = FALSE, hover = TRUE, align = "l")
  
  output$venn_plot <- renderPlot({
    req(rv$venn_plot)
    rv$venn_plot
  })
  
  output$prop_acc <- renderTable({
    req(rv$variable_summary)
    rv$variable_summary
  }, rownames = FALSE, striped = FALSE, hover = TRUE, align = "l")
  
  output$example_check <- renderPrint({
    req(rv$test)
    idx <- example_index()
    cat(paste0("Example ", idx, ":\n", rv$test$examples[idx]))
  })
  
  output$differences_df <- renderTable({
    req(rv$test)
    idx <- example_index()
    diffs <- rv$test$diff[[idx]]
    
    if (is.null(diffs) || nrow(diffs) == 0) {
      return(NULL)
    } else {
      diffs
    }
  }, striped = FALSE, hover = TRUE, bordered = TRUE, rownames = FALSE)
  
  output$omissssion_ex <- renderPrint({
    req(rv$test)
    idx <- example_index()
    omissions <- rv$test$O[idx]
    cat("Omissions:", omissions, "\n")
  })
  
  output$hallucinations_ex <- renderPrint({
    req(rv$test)
    idx <- example_index()
    halluc <- rv$test$H[idx]
    cat("Hallucinations:", halluc, "\n")
  })
  
  output$llm_output <- renderTable({
    req(rv$test, input$llm_model)
    idx <- example_index()
    llm_df <- rv$test[[input$llm_model]][[idx]]
    
    if (is.null(llm_df) || nrow(llm_df) == 0) {
      return(NULL)
    } else {
      return(llm_df)
    }
  }, rownames = FALSE, striped = FALSE, hover = TRUE, bordered = TRUE)
  
  output$key_output <- renderTable({
    req(rv$test)
    idx <- example_index()
    key_df <- rv$test$data[[idx]]
    
    if (is.null(key_df) || nrow(key_df) == 0) {
      return(NULL)
    } else {
      return(key_df)
    }
  }, rownames = FALSE, striped = FALSE, hover = TRUE, bordered = TRUE)
}
