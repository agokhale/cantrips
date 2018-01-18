### viamillipede:

Viamillipede is client and server program built to improve network pipe transport using multiple TCP sessions.  It multiplexes a single network pipe into multiple TCP connectons and then terminates the connections into a pipe transparently on another host.  It is similar to the simplest mode of remote pipe transparency of Netcat.

![alt text](theory_operation_viamillipede.svg "theory of operation")
#### Problems:

+ Single TCP connections have limitations on when they are expected to carry high throughput loads.
+ Poor mss window scaling. Congestion controls aggressively collapse mss when network conditions are not pristine.
+ Poor buffer interactions. "Shoe shining" when buffer sizing is not appropriate.
+ NewReno alternatives are not often acceptable.
+ Currently, flows are stuck on one physical interface.  This defeats the benefits of aggregation and multi-homed connections.

#### Goals and Features of viamillipede:

+ Provide:
     + Sufficent buffering for throughput.
     + Runtime SIGINFO inspection of traffic flow.`( parallelism, worker allocation, total throughput )`
     + Resilience against dropped TCP connections.`(*)`
+ Increase traffic throughput by:
     + Using parallel connections that each vie for survival against scaling window collapse.
     + Using multiple destination addresses with LACP/LAGG or separate Layer 2 adressing.
+ Intelligent Traffic Shaping:
     + Steer traffic to preferred interfaces.
     + Dynamically use faster destinations if preferred interfaces are clogged.
+ Make the compression/processing steps parallel. `(*)`
+ Architecture independence `(*)`

`(*)` denotes work in progress, because "hard * ugly > time"

#### Examples:

+ trivial operation
     + Configure receiver  with rx <portnum>
	` viamillipede rx 8834  `
     + Configure transmitter with  tx <receiver_host> <portnum> 
	` echo "Osymandias" | viamillipede tx foreign.shore.net 8834  `
+ verbose  <0-20>
	` viamillipede rx 8834   verbose 5 `
+ control worker thread count (only on transmitter) with threads <1-16>
	` viamillipede tx foreign.shore.net 8834 threads 16 `
+ use with zfs send/recv
     + Configure transmitter with  tx <receiver_host> <portnum>  and provide stdin from zfs send
	` zfs send dozer/visage | viamillipede tx foriegn.shore.net 8834  `
     + Configure receiver  with rx <portnum>  and ppipe output to zfs recv
     +	`viamillipede rx 8834   | zfs recv trinity/broken `

+ explicitly distribute load to reciever with multiple ip addresses, preferring the first ones used
     + Use the cheap link, saturate it, then fill the fast (north) transport and then use the last resort link (east) if there is still source and sync throughput available.
     + The destination machine has three interfaces and may have:
          + varying layer1 media ( ether, serial, Infiniband , 1488)
          + varying layer2 attachment ( vlan, aggregation )
          + varying layer3 routes
     + `viamillipede tx foreign-cheap-1g.shore.net 8834 tx foreign-north-10g.shore.net 8834  tx foreign-east-1g.shore.net 8834 `



```
TOP:
	scatter gather transport via multiple workers
	feet  are the work blocks
	start workers
	worker states
		idle
		working
	the window is the feet in flight
		window:
			foot (footid)
			stream start =  footid * footsize
			stream end =  (footid + 1) * footsize
			window [firstfoot, lastfoot]  ... heap? sorted for min foot out?

	sequence recieved feet to receate stream in order
	supervise the results relaibly.
	retrnsmit failed feet
	maximize throughput vs window vs latency product

	Retry broken transport works
```
