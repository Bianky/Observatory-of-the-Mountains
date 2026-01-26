# ---------- function to read & process a data ----------
process_theil <- function(folder, skip, n_max, col_names, drop_cols = NULL) {
  
  file_list <- list.files(
    path = file.path(path, folder),
    pattern = "\\.csv$", full.names = TRUE
  )
  
  dat <- map_dfr(file_list, function(f) {
    year <- str_extract(basename(f), "\\d{4}")
    
    read_csv(
      f, skip = skip,
      n_max = n_max,
      col_names = col_names,
      col_types = cols(.default = col_character()),
      show_col_types = FALSE
    ) %>%
      mutate(year = as.numeric(year))
  })
  
  # convert numerics
  dat <- dat %>%
    mutate(across(where(~ mean(grepl("^[0-9.-]+$", .x)) > 0.9),
                  ~ suppressWarnings(as.numeric(.x))))
  
  # drop any columns we don’t want to average
  dat_clean <- dat %>% select(-any_of(drop_cols))
  
  
  # Pyrenees mean
  data <- dat_clean %>%
    filter(county %in% cat) 

  
}


