# Load in packages 
library(googlesheets4)
library(dplyr)
library(stringr)
library(stringdist)
library(tibble)
library(tidyr)

# Read in data
POST <- read_sheet("https://docs.google.com/spreadsheets/d/1iAtAKj5xvX3aGlIrjeJqyDMvDGM222assSt4N8Kg6vI/edit?gid=1230698527#gid=1230698527", sheet = "Sheet5")
PRE <- read_sheet("https://docs.google.com/spreadsheets/d/1iAtAKj5xvX3aGlIrjeJqyDMvDGM222assSt4N8Kg6vI/edit?gid=1230698527#gid=1230698527", sheet = "Sheet6")

# Adjust column names in POST 

POST <- POST %>% 
  rename(
    'Student Name' = 'What is your name? Please include your first and last name.',
    'Grade' = 'What grade are you in?'
  )

# Fuzzy match names in PRE and POST 
# Prepare Student Name column # All lower case, no ws or punctuation 

PRE <- PRE %>%
  mutate(
    clean = str_to_lower(str_replace_all(`Student Name`, "[^a-zA-Z]", ""))
  )

POST <- POST %>%
  mutate(
    clean = str_to_lower(str_replace_all(`Student Name`, "[^a-zA-Z]", ""))
  )

# String distance metric measures how different or similar two text string are # Potentially use Levenshtein distance or Jaro-Winkler 
# Pairwise distance matrix # johnsmith and jonhsith will have a distance of 2

# Subset by grade  

grade_match <- "5th grade"

PRE_sub <- PRE %>% filter(Grade == grade_match)
POST_sub <- POST %>% filter(Grade == grade_match)

# Compute pairwise LV distance 

distance_matrix <- stringdistmatrix(PRE_sub$clean, POST_sub$clean, method = "lv")
print(distance_matrix)

closest_match <- apply(distance_matrix, 1, function(row) {
  min_dist <- min(row)
  best_matches <- which(row == min_dist)
  list(min_distance = min_dist, matched_POST_index = best_matches)
})


# Create a data frame of PRE names and their closest match info
matches_df <- tibble(
  PRE_index = seq_along(closest_match),
  PRE_name = PRE_sub$clean,
  min_distance = sapply(closest_match, function(x) x$min_distance),
  POST_indices = sapply(closest_match, function(x) paste(x$matched_POST_index, collapse = ","))
)

# POST matches to actual names
matches_df <- matches_df %>%
  rowwise() %>%
  mutate(
    POST_names = paste(POST_sub$clean[as.integer(strsplit(POST_indices, ",")[[1]])], collapse = ", ")
  ) %>%
  ungroup()

# Add uncleaned names
matches_df <- matches_df %>%
  mutate(
    PRE_original = PRE_sub$`Student Name`,
    POST_original = paste(POST_sub$`Student Name`[as.integer(strsplit(POST_indices, ",")[[1]])], collapse = ", ")
  )

print(matches_df)

# Create data frame of all possible pairs with distances
pairs <- expand.grid(PRE_idx = 1:nrow(PRE_sub), POST_idx = 1:nrow(POST_sub)) %>%
  mutate(distance = stringdist(PRE_sub$clean[PRE_idx], POST_sub$clean[POST_idx], method = "lv")) %>%
  filter(distance <= 2) %>%  # distance threshold to keep # 2 is ideal in this case? juan matched with three students when set to 3
  arrange(distance)

# Greedy assign matches without repeating POST and PRE indices
matched_POST <- integer(0)
matched_PRE <- integer(0)
matched_pairs <- data.frame()

for (i in seq_len(nrow(pairs))) {
  if (!(pairs$POST_idx[i] %in% matched_POST) && !(pairs$PRE_idx[i] %in% matched_PRE)) {
    matched_pairs <- rbind(matched_pairs, pairs[i, ])
    matched_POST <- c(matched_POST, pairs$POST_idx[i])
    matched_PRE <- c(matched_PRE, pairs$PRE_idx[i])
  }
}
# Add original names from PRE and POST to matched_pairs
matched_pairs <- matched_pairs %>%
  mutate(
    PRE_name = PRE_sub$`Student Name`[PRE_idx],
    POST_name = POST_sub$`Student Name`[POST_idx]
  )

# I want to check which names did NOT get matched 

# All PRE indices
all_PRE <- 1:nrow(PRE_sub)
# All POST indices
all_POST <- 1:nrow(POST_sub)

# PRE not matched
unmatched_PRE <- setdiff(all_PRE, matched_PRE)
# POST not matched
unmatched_POST <- setdiff(all_POST, matched_POST)


a <- PRE_sub[unmatched_PRE, c("Student Name", "clean")]
b <- POST_sub[unmatched_POST, c("Student Name", "clean")]

# Create some sort of a test set with true matches as 1 and non matches done as 0 (done manually) to test code and accuracy

# Create a pairs data frame with the original names and distance
pairs_to_check <- pairs %>% 
  mutate(
    PRE_name = PRE_sub$`Student Name`[PRE_idx],
    POST_name = POST_sub$`Student Name`[POST_idx]
  ) %>% 
  select(PRE_idx, POST_idx, PRE_name, POST_name, distance)

# Full cross join to create a datset with post names, pre names, indexes, blank column for me to fill out, and the length will be every possible combination of each student name

match_check <- expand.grid(
  PRE_idx = 1:nrow(PRE_sub),
  POST_idx = 1:nrow(POST_sub)
) %>%
  mutate(
    PRE_name = PRE_sub$`Student Name`[PRE_idx],
    POST_name = POST_sub$`Student Name`[POST_idx],
    match_label = ""
    ) %>%
  select(PRE_idx, PRE_name, POST_idx, POST_name, match_label)

# Include string distance 

match_check <- match_check %>% 
  mutate(
    distance = stringdist(PRE_sub$clean[PRE_idx], POST_sub$clean[POST_idx], method = "lv")
  )

# Export to Google Sheet for manual checking to create test set 

sheet_write(match_check, ss = "https://docs.google.com/spreadsheets/d/1iAtAKj5xvX3aGlIrjeJqyDMvDGM222assSt4N8Kg6vI/edit?gid=1764552559#gid=1764552559", sheet = "Match Check Test Set")



