#!/usr/bin/nawk -f
/disk/ {
	FS=":"
	ldiskdev = $5
	grepsuccess="grep " ldiskdev  " infiles/glabel.out " | getline sesline
	if ( grepsuccess ) {
		split (sesline, sessplit , " " )
		vdev_leaf = sessplit[1]
		grepleafsuccess="grep " vdev_leaf  " tmpfiles/pool.normal " | getline poolline	
		if ( grepleafsuccess ) { 
			print  $0 " " poolline
		} else 	 {
			print  $0 " " vdev_leaf " no_pool"
		}
	}
	
}
