# Student Record Matching Using Fuzzy String Matching

## Overview

This project demonstrates a methodology for linking student survey responses across multiple collection periods when no unique student identifier is available.

In longitudinal survey analysis, it is often necessary to determine whether records from a pre-survey and post-survey belong to the same student. Because students may enter their names differently across surveys, exact matching can result in missed matches and inaccurate analyses.

To address this challenge, I developed a fuzzy matching workflow in R that identifies likely record matches based on string similarity while minimizing duplicate assignments.

## Problem

The dataset contained student survey responses collected at multiple time points. No unique identifier was available to reliably connect records across surveys.

Common challenges included:

* Misspelled names
* Inconsistent capitalization
* Extra spaces or punctuation
* Alternative spellings
* Multiple potential matches

Without a matching process, longitudinal analysis could not be performed reliably.

## Methodology

### Data Preparation

Student names were standardized by:

* Converting all text to lowercase
* Removing punctuation
* Removing spaces and special characters

This reduced variation caused by formatting differences.

### Similarity Scoring

Levenshtein distance was used to measure the number of character edits required to transform one name into another.

Lower distances indicate higher similarity between names.

### Matching Strategy

To improve matching accuracy:

1. Records were first grouped by grade level.
2. Pairwise string distances were calculated between all possible name combinations.
3. Candidate matches below a specified distance threshold were retained.
4. A greedy assignment algorithm was used to prevent duplicate matches and create one-to-one record pairings.

### Validation

To evaluate performance, a labeled testing dataset was created by generating all possible pre/post survey combinations and manually identifying true matches.

This test set was used to assess matching accuracy and refine distance thresholds.

## Skills Demonstrated

* R Programming
* Data Cleaning and Standardization
* Fuzzy String Matching
* Record Linkage
* Algorithm Design
* Validation and Testing
* Longitudinal Data Analysis

## Privacy

The original project utilized confidential student data and cannot be shared publicly. Any example datasets included in this repository are synthetic and intended solely to demonstrate the methodology.
