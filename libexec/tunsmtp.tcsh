#!/bin/tcsh
while ( 1 == 1)

	ssh -v  -o "TCPKeepAlive yes"  -N -L 2225:localhost:25 aeria.net  
end
