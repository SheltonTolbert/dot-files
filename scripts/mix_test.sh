#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

get_changed_tests() {
  git diff --name-only | grep test.exs 
}

get_test_cases() {
  xargs -L 1 -I{} grep -n 'test "' $REPO_ROOT/{}
}

get_test_case_line_number() {
  awk -F ':' '{print $1}'
}

get_changed_test_cases_for_file() {
  CHANGED_TEST_BLOCKS=$(git diff -p "$REPO_ROOT/$1" | grep '^@@' | cut -d',' -f1 | cut -d'-' -f2)
  FILE_TEST_BLOCKS=$(echo "$1" | get_test_cases | get_test_case_line_number)
  TEST_CASES=()
  FILE="$1"

  printf -v file '%s\n' "$FILE_TEST_BLOCKS"    # File blocks are now the first file
  printf -v changed '%s\n' "$CHANGED_TEST_BLOCKS" # Changed blocks are the second file

  RESULTS=$(awk '
    NR==FNR { a[$1]; next }  # Store FILE_TEST_BLOCKS in array 'a'
    {
      b = $1                 # Current block from CHANGED_TEST_BLOCKS
      closest = ""
      closest_val = ""       # Store the closest value from FILE_TEST_BLOCKS
      for (i in a) {
        diff = (i - b)*(i - b)
        if (closest == "" || diff < (closest - b)*(closest - b)) {
          closest = i       # Closest value is from FILE_TEST_BLOCKS
          closest_val = i  # Store the closest value from FILE_TEST_BLOCKS
        }
      }
      print closest_val     # Print the closest value from FILE_TEST_BLOCKS
    }
  ' <(echo "$file") <(echo "$changed")) # Order is now <(echo "$file") <(echo "$changed")

  echo "$RESULTS"
}

# get_changed_tests | get_test_case_line_numbers 

get_changed_test_cases_for_file $1

