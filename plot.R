library(tidymodels)
library(jsonlite)

prepare_line <- function(x) {
  x %>%
    modify_at("config", list) %>%
    as_tibble()
}

results <- read_json("results/2022-10-21/5a19157-results.json") %>%
  map_dfr(prepare_line) %>%
  unnest_wider(config, transform = as.character) %>%
  mutate(
    name = as.character(name),
    version = as.character(version),
    BATCH_SIZE = as.numeric(BATCH_SIZE),
    ITER = as.numeric(ITER),
    time = readr::parse_number(as.character(time)),
    platform = as.character(platform)
  ) %>%
  mutate(time = time/ITER)

py_reference <- results %>%
  filter(LANGUAGE == "py") %>%
  group_by(name, BATCH_SIZE, DEVICE) %>%
  summarise(
    time_py = mean(time, trim = 0.2, na.rm = TRUE),
    .groups = "drop"
  )

r_results <- results %>%
  filter(LANGUAGE == "r") %>%
  group_by(VERSION, name, BATCH_SIZE, DEVICE, VECTORIZED_DS) %>%
  summarise(
    time_r = mean(time, trim = 0.2, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(py_reference, by = c("name", "BATCH_SIZE", "DEVICE")) %>%
  mutate(time_rel = time_r/time_py)

r_results %>%
  filter(DEVICE == "cuda") %>% View()
  replace_na(list(VECTORIZED_DS = "")) %>%
  ggplot(aes(x = BATCH_SIZE, y = time_rel, color = VERSION)) +
  geom_point(aes(shape = VECTORIZED_DS)) +
  geom_line(aes(linetype = VECTORIZED_DS)) +
  facet_wrap(~name, ncol = 3, scales = "free") +
  geom_hline(yintercept = 1, aes(color = "python"), linetype = "dashed") +
  scale_shape(guide = "none")

