#!/bin/tcsh

foreach i ( `cat package_list` ) 
	yes | pkg install  $i 
end
