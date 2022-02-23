library(tidyverse)

old_trials <- read_csv('imaze-trials.csv')

new_trials <- 
  old_trials %>% 
  group_by(item, suite, condition, sentence ) %>% 
  summarize(
    targets = stringr::str_flatten(word, collapse = "|"),
    competitors = stringr::str_flatten(alternative, collapse = "|"),
    l_maze = stringr::str_flatten(l_maze, collapse = "|"),
    critical_region = stringr::str_flatten(critical_region, collapse = "|"),
    region_number = stringr::str_flatten(region_number, collapse = "|"),
    freqlog10 = stringr::str_flatten(freqlog10, collapse = "|"),
    len = stringr::str_flatten(len, collapse = "|")
  )

write_csv(new_trials, 'imaze-trials-full.csv')

# and some statistics

with(new_trials, table(suite,condition))

new_trials %>% group_by(suite, condition, item) %>% 
  summarize(n()) %>% View()

filter(new_trials, condition == "that_nogap") %>% View()
