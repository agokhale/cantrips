#!/usr/bin/awk -f

#generate all the combinations of all the letters
#ubrute.awk -vcdict='asdf' -vlen=3

function cdx(idx,     ca){
  split (cdict, ca, "");
	return (ca[idx]);
}

function rain (depth,a,     ccur){
	if (depth == 0) {
		printf("%s\n",a);
		return (0);
		}
  ccur = length(cdict)	+ 1
	
	ar="";
  while (ccur-- > 0) {
		rain(depth-1, ar);
		ar = sprintf("%s%s",  cdx(ccur),a)
	}
}

BEGIN {
	if (cdict == "") {
		cdict="abcdefghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890- !@#$%^&*()'";
		}
	rain(len,"")
	exit(0);
}
