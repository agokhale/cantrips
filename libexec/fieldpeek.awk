#!/usr/bin/awk -f

# provide a view of whats in the the fields of a big csv 
BEGIN{
  FS=",";
}

// { 
  for (i=1; i<= NF; i++) { printf ("%s:uwu:%s\n",i, $i); }
  printf("------------------------------------------------NR=%s NF=%s\n" , NR, NF); 
  #if (NR > 1) exit(1); 
}

