#!/usr/bin/awk -f 
BEGIN {
pfx="na"
}

/url_prefix/  {
#prefix anly = Blueprint('coolmap', __name__, url_prefix='/REST/coolmap'
gsub( "^.*url_prefix", "");
#print("prefix", $0);
pfx=$0;
}

/route\(/  {
gsub ( "^.*@.*route\\(", "")
print( FILENAME, FNR, pfx,   $0 );
}

