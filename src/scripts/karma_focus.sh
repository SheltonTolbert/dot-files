#!/bin/bash

grep "Chrome Headless" | grep -v "Executed"  | fzf | awk '{for(i=1;i<=NF;i++) if($i=="FAILED") {for(j=i-5;j<i;j++) printf "%s ", $j; print ""}}'  | xargs -I{} grep -rl {} ./src | xargs -I{} yarn test:rtl --file {}
