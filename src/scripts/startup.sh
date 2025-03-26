#!/bin/bash

# @doc
# A script for initializing my development enviroment 
#

# start tmuxinator sessions

tmuxinator start axon --attach=false
tmuxinator start dendra --attach=false
tmuxinator start servers --attach=false
tmuxinator start config --attach=false
tmuxinator start obsidian --attach=false

# setup aerospace workspaces
#
#   workspace 4: slack | arc
#   workspace 5: ghostty
#   workspace 6: ghostty | arc
#   workspace 2: arc
