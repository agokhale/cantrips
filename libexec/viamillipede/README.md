###viamillipede: 

A client and server programt for network pipe transport using mulitple tcp sessions.  It muliplexes a single pipe into mulitple tcp connectons and  terminates them into a pipe transparently on another host.  It's not dissimlar to  netcat's simplest mode of remote pipe transparency

####Problems: 

+ Single TCP connections have limitations when they are expected to carry high throughput loads.
+ poor mss window scaling, congestion controlls aggessively collapse mss when network conditions are not prestine.
+ poor buffer interactions, 'shoe shining' when buffer sizing is not appropriate 
+ newreno alternatives are not often acceptable 
+ flows are stuck to one physical interface,defeats benefits of aggregation and multihomed connections 

####Goals/Features:

+ provide sufficent buffering for throughpout
+ increase throughput by using parallel connections that can each vie for survial against scaling window collapse
+ increate throughput by using muliple destination address, via lacp/lagg or seprate Layer 2 adressing
+ steer traffic to preferred interfaces 
+ greedily use faster destinations if preferred interfaces are clogged
+ provide runtime SIGINFO inspection of traffic flow ( parallelism, worker allocation , total throughput ) 
+ provide resiliancy against dropped tcp connections(*)
+ parallelize compression/porcessing steps (*)
+ architechure independance (*)

###(*) work in progress, because hard*ugly > time

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
