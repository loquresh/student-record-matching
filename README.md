# Student Record Matching Using Fuzzy String Matching

Linking pre- and post-survey responses for the same students is essential for measuring program impact, but the surveys had no shared student ID. This project matches records across survey periods using name similarity alone, with R, so that longitudinal analysis becomes possible. It was developed for a nonprofit's student survey program, which collected thousands of responses per cycle across dozens of school sites.

## Key Results

- **Approach:** Names were standardized, compared with Levenshtein distance within grade-level groups, and assigned one-to-one with a greedy algorithm to prevent duplicate matches.
- **Accuracy:** [X% of true matches correctly identified, Y% false match rate, based on a manually labeled test set]
- **Impact:** [one line on what the matching made possible, e.g. pre/post analysis of program outcomes that wasn't previously feasible]

## Data Source
Student survey responses collected at multiple time points, originally gathered as part of a nonprofit longitudinal survey project.

*Note: The original data is confidential student data and is not included in this repository. Any example data included here is synthetic and only meant to demonstrate the methodology.*

## Data Quality Notes
Since there was no unique ID to match records across surveys, records had to be linked using names, which introduced a few real challenges:
- Misspelled names
- Inconsistent capitalization
- Extra spaces or punctuation
- Alternative spellings of the same name
- Multiple possible matches for a single record

Without addressing these, longitudinal analysis across the two surveys wasn't possible.

## Methodology

### 1. Data Preparation
Names were standardized before comparing them, by converting all text to lowercase, removing punctuation, and removing spaces and special characters. This cut down on a lot of the variation that was really just formatting differences, not different names.

### 2. Similarity Scoring
Levenshtein distance was used to measure how many character edits it takes to turn one name into another. A lower distance means the two names are more similar.

### 3. Matching Strategy
A few steps were used to keep the matching accurate:
- Records were first grouped by grade level, to narrow down comparisons to a smaller, more relevant pool.
- Pairwise string distances were calculated between all possible name combinations within each group.
- Candidate matches below a set distance threshold were kept.
- A greedy assignment algorithm was used from there, so each record only got matched once, avoiding duplicates.

### 4. Validation
To check how well this worked, a labeled test set was built by generating all possible pre/post survey combinations and manually marking the true matches. This test set was used to measure accuracy and adjust the distance threshold.

## Tools
R
