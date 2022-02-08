#!/usr/bin/awk -f 
BEGIN{ 
  FS=":uwu:"; 
  rnum=0;
  top_dex =0; 
  prev_top_dex =0; 
  recnum=0; 
  record[0] ="nop"
}

/^--------------/ {  rnum++;  
  #print ("next:", top_dex); 

  recnum++; 
  if (record[1])  {
    for ( i=1; i <= top_dex; i++ ){
      printf( "%s", record[i]); 
      if (i<top_dex) printf("|");
    }
    printf( "\n"); 
  }
  for( i =1; i< 1000; i++){
    delete record[i];  
  }
  if (recnum>2) {
    if (prev_top_dex != top_dex) { 
      print("feild count mismatch",$0, "max",top_dex, "prevmax",prev_top_dex,  "record",recnum  );  
      exit (3); 
    }
  }
  prev_top_dex = top_dex; 
  top_dex=0; 
}

/uwu/ {
  record[$1]=$2;
  if ( $1 > top_dex) top_dex =$1; 
}
