joinses:  glabel liveses  livepool
	cat tmpfiles/ses.normal | ./join_ses.nawk

joinpool:  dir  glabel liveses livepool
	cat tmpfiles/pool.normal | ./join_pool.nawk
pool:  
	cat infiles/zpool.out | ./normalize_pool.nawk
livepool: dir
	zpool status | ./normalize_pool.nawk | tee tmpfiles/pool.normal
ses: 
	cat infiles/sesutil.out | ./normalize_ses.nawk
glabel:  dir
	glabel status  >  infiles/glabel.out
liveses:  dir
	sesutil map | ./normalize_ses.nawk | tee tmpfiles/ses.normal

dir: 
	mkdir -p tmpfiles
	mkdir -p infiles

clean:  
	rm -r tmpfiles infiles
