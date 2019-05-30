#!/usr/bin/awk -f


/^[a-zA-Z]*\:/ {FS=":";  print $1   }

NR==2048 {print NR,"stop"; exit(0)}
