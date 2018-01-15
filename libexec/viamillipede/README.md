### viamillipede: 

Viamillipede is client and server program for network pipe transport using mulitple tcp sessions.  It muliplexes a single pipe into mulitple tcp connectons and terminates them into a pipe transparently on another host.  It is not dissimlar to netcat's simplest mode of remote pipe transparency

#### Problems: 

+ Single TCP connections have limitations when they are expected to carry high throughput loads.
+ Poor mss window scaling. Congestion controls will aggessively collapse mss when network conditions are not prestine.
+ Poor buffer interactions. 'Shoe shining' when buffer sizing is not appropriate. 
+ NewReno alternatives are not often acceptable 
+ Currently flows are stuck to one physical interface.  Unfortunately it defeats the benefits of aggregation and multihomed connections 

#### Goals/Features:

+ Provide:
     + Sufficent buffering for throughput.
     + Runtime SIGINFO inspection of traffic flow ( parallelism, worker allocation , total throughput ) 
     + Resiliancy against dropped tcp connections(*)
+ Increase throughput by:
     + Using parallel connections that can each vie for survial against scaling window collapse.
     + Using muliple destination address, via lacp/lagg or seprate Layer 2 adressing.
+ Intellegent Traffic Shaping
     + Steer traffic to preferred interfaces 
     + Greedily use faster destinations if preferred interfaces are clogged.
+ Make the compression/porcessing steps parallel. (*)
+ Architechure independance (*)

#### (*) work in progress, because hard*ugly > time

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
