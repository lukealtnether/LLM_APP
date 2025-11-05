validation_server <- function(input, output, session) {
  rv <- reactiveValues(
    df1 = NULL,
    df2 = NULL,
    combined_df = NULL,
    val_colnames = NULL,
    validation_index = 1
  )
  
  observe({
    updateSelectInput(
      session,
      "val_id",
      choices = c("None" = "", rv$val_colnames),
      selected = ""
    )
  })
  
  # ---- Reader 1 Upload ----
  observeEvent(input$reader_1_xlsx, {
    req(input$reader_1_xlsx)
    reader_1 <- read_excel(input$reader_1_xlsx$datapath, col_names = TRUE)
    rv$df1 <- reader_1 %>%
      select(examples, ends_with("_app")) %>%
      rename_with(~ sub("_app$", "", .x), ends_with("_app")) %>%
      nest(data = -examples)
    first_nested <- rv$df1$data[[1]]
    rv$val_colnames <- names(first_nested)
  })
  
  # ---- Reader 2 Upload ----
  observeEvent(input$reader_2_xlsx, {
    req(input$reader_2_xlsx)
    reader_2 <- read_excel(input$reader_2_xlsx$datapath, col_names = TRUE)
    rv$df2 <- reader_2 %>%
      select(examples, ends_with("_app")) %>%
      rename_with(~ sub("_app$", "", .x), ends_with("_app")) %>%
      nest(data = -examples)
  })
  
  # ---- Adjudicate ----
  observeEvent(input$adjudicate_llm, {
    req(rv$df1, rv$df2)
    
    val_id <- input$val_id
    if (identical(val_id, "")) val_id <- NULL
    
    rv$combined_df <- left_join(rv$df1, rv$df2, by = "examples", suffix = c(".x", ".y")) %>%
      rowwise() %>%
      mutate(
        diffs = list({
          cmp <- comparedf(data.x, data.y, by = val_id, int.as.num = TRUE)
          diff_tbl <- tryCatch({
            diffs(cmp) %>%
              rename(
                variable = var.x,
                reader_1 = values.x,
                reader_2 = values.y
              ) %>%
              mutate(true = 1) %>%
              relocate(any_of(val_id))
          }, error = function(e) tibble(variable = NA, reader_1 = NA, reader_2 = NA))
          diff_tbl
        }),
        gt = list({
          if (nrow(data.x) >= nrow(data.y)) data.x else data.y
        }),
        gt_n = if (nrow(data.x) >= nrow(data.y)) 1 else 2
      ) %>%
      ungroup()
    
  })
  
  # ---- Navigation ----
  observeEvent(input$next_validation, {
    req(rv$combined_df)
    if (rv$validation_index < nrow(rv$combined_df)) {
      rv$validation_index <- rv$validation_index + 1
    }
  })
  
  observeEvent(input$previous_validation, {
    req(rv$combined_df)
    if (rv$validation_index > 1) {
      rv$validation_index <- rv$validation_index - 1
    }
  })
  
  observe({
    req(rv$combined_df)
    max_idx <- nrow(rv$combined_df)
    
    # Disable/enable buttons based on position
    toggleState("next_validation", condition = rv$validation_index < max_idx)
    toggleState("previous_validation", condition = rv$validation_index > 1)
  })
  
  # ---- Example display ----
  output$example_validate <- renderPrint({
    req(rv$combined_df)
    idx <- rv$validation_index
    cat(paste0(idx,"/", nrow(rv$df1), ":\n", rv$combined_df$examples[idx]))
  })
  
  # ---- Show diffs table ----
  output$validation_differences <- renderDT({
    req(rv$combined_df)
    idx <- rv$validation_index
    diff_df <- rv$combined_df$diffs[[idx]]
    val_id <- input$val_id
    if (identical(val_id, "")) val_id <- NULL
    
    if (is.null(diff_df) || nrow(diff_df) == 0 || all(is.na(diff_df$variable))) {
      datatable(
        data.frame(Message = "No differences found/ Cannot Compare"),
        options = list(dom = "t"),
        rownames = FALSE
      )
    } else {
      # Find the index of the "true" column (0-indexed)
      true_col_idx <- which(colnames(diff_df) == "true") - 1
      
      # Get all other column indices to disable
      all_cols <- seq(0, ncol(diff_df) - 1)
      cols_to_disable <- all_cols[all_cols != true_col_idx]
      
      # Columns to *display* in the UI
      visible_cols <- c(val_id, "variable", "reader_1", "reader_2", "true")
      hidden_cols <- which(!colnames(diff_df) %in% visible_cols) - 1
      
      datatable(
        diff_df,
        editable = list(target = "cell", disable = list(columns = cols_to_disable)),
        rownames = FALSE,
        options = list(
          dom = "t",
          ordering = FALSE,
          searching = FALSE,
          paging = FALSE,
          info = FALSE,
          scrollX = TRUE,
          columnDefs = list(list(visible = FALSE, targets = hidden_cols))
        )
      )
    }
  }, editable = TRUE)
  
  
  observeEvent(input$validation_differences_cell_edit, {
    info <- input$validation_differences_cell_edit
    idx <- rv$validation_index
    
    # Reference the diffs and gt for this example
    diff_df <- rv$combined_df$diffs[[idx]]
    gt_df <- rv$combined_df$gt[[idx]]
    
    # 1. Update the edited cell in diffs
    diff_df[info$row, info$col + 1] <- info$value
    
    # 2. Use the updated diffs to rebuild gt
    for (i in seq_len(nrow(diff_df))) {
      d <- diff_df[i, ]
      
      # Skip NA rows
      if (is.na(d$variable) || is.na(d$true)) next
      
      # Determine correct value and row index
      if (d$true == 1) {
        correct_val <- d$reader_1
        row_to_update <- d$row.x
      } else {
        correct_val <- d$reader_2
        row_to_update <- d$row.y
      }
      
      # Only update if row index is valid
      if (!is.na(row_to_update) && row_to_update <= nrow(gt_df)) {
        gt_df[[d$variable]][row_to_update] <- correct_val
      }
    }
    
    # 3. Save updated diffs and gt back to reactiveValues
    rv$combined_df$diffs[[idx]] <- diff_df
    rv$combined_df$gt[[idx]] <- gt_df
  })
  
  
  
  output$validation_gt <- renderDT({
    req(rv$combined_df)
    idx <- rv$validation_index
    gt_df <- rv$combined_df$gt[[idx]]
    
    datatable(gt_df,
      editable = list(target = "cell"),
      rownames = FALSE,
      options = list(
        dom = "t",
        ordering = FALSE,
        searching = FALSE,
        paging = FALSE,
        info = FALSE,
        scrollX = TRUE))
  })
  
  observeEvent(input$add_row_val, {
    req(rv$combined_df)
    idx <- rv$validation_index
    gt_df <- rv$combined_df$gt[[idx]]
    
    # Create an empty row with the same columns
    new_row <- as.list(rep(NA, ncol(gt_df)))
    names(new_row) <- colnames(gt_df)
    
    # Add it to the bottom
    gt_df <- bind_rows(gt_df, new_row)
    
    # Save back to reactiveValues
    rv$combined_df$gt[[idx]] <- gt_df
  })
  
  observeEvent(input$remove_row_val, {
    req(rv$combined_df)
    idx <- rv$validation_index
    gt_df <- rv$combined_df$gt[[idx]]
    
    if (nrow(gt_df) > 0) {
      # Remove the last row
      gt_df <- gt_df[-nrow(gt_df), ]
      rv$combined_df$gt[[idx]] <- gt_df
    }
  })
  
  observeEvent(input$validation_gt_cell_edit, {
    info <- input$validation_gt_cell_edit
    idx <- rv$validation_index
    
    # Reference the current gt dataframe
    gt_df <- rv$combined_df$gt[[idx]]
    
    # Update the edited cell
    gt_df[info$row, info$col + 1] <- info$value
    
    # Save it back to reactiveValues
    rv$combined_df$gt[[idx]] <- gt_df
  })
  
  
  
  # ---- Reader data preview ----
  output$reader_1_output <- renderTable({
    req(rv$combined_df)
    idx <- rv$validation_index
    rv$combined_df$data.x[[idx]]
  })
  
  output$reader_2_output <- renderTable({
    req(rv$combined_df)
    idx <- rv$validation_index
    rv$combined_df$data.y[[idx]]
  })
  
  output$download_ground_truth <- downloadHandler(
    filename = function() {
      name <- input$filename_ground_truth
      if (name == "") name <- "ground_truth"
      paste0(name, ".xlsx")
    },
    content = function(file) {
      req(rv$combined_df)
      req(input$reader_1_xlsx)
      
      # Read Reader 1 and get non-_app columns
      reader_1 <- read_excel(input$reader_1_xlsx$datapath, col_names = TRUE) %>%
        select(-ends_with("_app"), -ends_with("latest_time")) %>%   # keep only metadata columns
        distinct()                       # remove duplicate rows
      
      # Prepare GT output
      rv$combined_df %>%
        select(examples, gt) %>%                             # keep examples and gt
        mutate(gt = map(gt, ~ setNames(.x, paste0(names(.x), "_app")))) %>%  # rename nested gt columns
        unnest(gt) %>%                                       # flatten nested gt
        left_join(reader_1, by = "examples") %>%            # add back metadata
        writexl::write_xlsx(path = file)                    # save to Excel
    }
  )

}