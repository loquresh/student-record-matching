# Student Record Matching Using Fuzzy String Matching

## Overview
This project demonstrates a way to link student survey responses across multiple collection periods when no unique student identifier is available.

## Project Question
Can student records from a pre-survey and post-survey be reliably matched to the same student using name similarity alone, when no unique identifier connects them?

This breaks down into a few sub-questions:
- How much do names vary in formatting and spelling across the two surveys?
- What similarity method can reliably measure how close two names are?
- How can matches be assigned without creating duplicates?
- How accurate is the resulting matching process?

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
