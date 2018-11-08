#!/bin/sh
echo signature:$1 rate:$2

frog<<TUWAAT
BEGIN{ }

$1 {
	@h[probemod,probefunc, probename] = count(); 
}

tick-4s { 
	printa(@h);
	trunc(@h);
}

TUWAAT

echo $frog
