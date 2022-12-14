run_benchmark <- function(file = "bench.yaml") {
  configs <- parse_config(file)
  results <- list()
  for (i in seq_along(configs)) {
    cat("[", i, "/", length(configs), "]", configs[[i]]$name, "|",
        conf_summary(configs[[i]]))
    time <- system.time({
      results[[i]] <- execute_experiment(configs[[i]])
    })
    cat(" TOTAL_TIME_ELLAPSED:", time[["elapsed"]], "\n")
  }
  # make config a named list, so jsonlite casts it to json dicts.
  results <- purrr::map(results, ~purrr::modify_at(.x, "config", as.list))
  path <- glue::glue("results/{Sys.Date()}/{short_hash(results)}-results.json")
  fs::dir_create(
    fs::path_dir(path),
    recurse = TRUE
  )
  jsonlite::write_json(
    results,
    path
  )
}

conf_summary <- function(config) {
  config <- config$config
  nms <- paste0(names(config), ":")
  values <- config
  c(rbind(nms, values))
}

short_hash <- function(result) {
  substr(digest::digest(result), 1, 7)
}

