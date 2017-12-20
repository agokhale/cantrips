viamillipede muliplexes a single pipe into mulitple tcp connectons and  terminates them into a pipe on another host. 

goals:
- provide resiliancy against dropped tcp connections?
- increase b/w utilizaton 
- parallelize compression/porcessing steps

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

