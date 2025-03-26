#!/bin/bash

# DFM.1.0                                  .Do it for me
# ======================================================
#
#  

if [ $# -eq 0 ]; then
  echo "Error: No arguments provided."
  exit 1
fi

script_name="$*"
script_name="${script_name// /_}.sh"

script_dir="$(dirname "$0")"

if [ -f "$script_dir/$script_name" ]; then
  "$script_dir/$script_name"
else
  echo "Error: File '$script_name' does not exist in the script directory."
fi
