library(tidyverse)

old_trials <- read_csv('../../magpie3-imaze-nlms/trials/imaze-trials.csv')

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
  ) %>% 
  ungroup()

# main trials
write_csv(new_trials %>% filter(! is.na(suite)), 'imaze-trials-full.csv')
# fillers
write_csv(new_trials %>% filter(condition == "filler"), 'imaze-trials-fillers.csv')
# practice
write_csv(new_trials %>% filter(condition == "practice"), 'imaze-trials-practice.csv')

# get conditions

new_trials %>% filter( ! is.na(suite)) %>% 
  select(suite, condition) %>% 
  unique() %>% 
  write_csv('conditions.csv')

# and some statistics

with(new_trials, table(suite,condition))

new_trials %>% group_by(suite, condition) %>% 
  summarize(
    n = n(),
    item_count = length(item),
    items = str_c(item, collapse = ",")
  ) %>% 
  View()

new_trials %>% pull(item) %>% unique() %>% length()
  
filter(new_trials, condition == "that_nogap") %>% View()
