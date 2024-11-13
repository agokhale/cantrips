# cantrips
systems lore with dubious provenance

```mermaid

---
title: getting it
---

%%{init: {"flowchart": {"htmlLabels": false} }%%

flowchart TB
	%% Line Comments  from yaml?
	init --> |"pll lock"| A
	A -->|standby| wait@{ shape: hourglass,  label:["ru meditation"] }
	A -->|event| log@{ shape: paper-tape, label:["guru meditation"]}
	wait --> |hangtime|A
	A --inline ---error{"~~bad~~ _**zoot**_
	[documentation link should work](https://mermaid.js.org/syntax/flowchart.html)
	<a href='https://mermaid.js.org/syntax/flowchart.html'> mermaid docs</a>"
	}
	A ==> B[(dbquery)]
	B --x |disconn line| error
	B ==> C((thinking.exe))
	C o--o |bang| error 
	C ==> done>weird asymetric bracket]
	error ---> spanking("rst")
	spanking --> thinking

	subgraph initworld 
		direction RL
		thinking --> acting
		acting -->|brrr| thunking
		thunking --> thinking
	end
	thunking -- weeee! --> A

```

