# ---------- function to read & process a data ----------
process_map <- function(folder, skip, n_max, col_names, drop_cols = NULL, fun) {
  
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
  pyr_data <- dat_clean %>%
    filter(county %in% pyr) 
  
  # Catalonia mean
  cat_data <- dat_clean %>%
    filter(county %in% cat) %>%
    group_by(year) %>%
    summarise(across(where(is.numeric), ~fun(.x, na.rm = TRUE))) %>%
    mutate(county = "Catalunya")
  
  bind_rows(pyr_data, cat_data) %>%
    filter(year > 2014)

}
