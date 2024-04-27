#!/bin/sh -ex
outfmt="cdr"
soxflags="-V4" # verbose
outrate="44100"
cdrom_scsiid="9,0,0"

# -v sets vry high SR conversion
# vol 0.98 should eat hard clips - mostly :/

find . -name "*.wav" -print0 | \
  xargs -0 -n1 -I% \
    sox  $soxflags  "%" "%".$outfmt  \
      vol 0.98 \
      rate -v $outrate

#cdrom=` cdrecord -scanbus | grep CD-ROM | cut -w  -f2 ` ## needs a bunch of  root perms for the pass, xpt drivers
# incomplete devfs
#own     cd0     root:operator
#perm    cd0     0660
#operator should be able to cdrecord -scanbus
#own     xpt0    root:operator
#perm    xpt0    0660

echo cdrecord dev=$cdrom_scsiid -v -audio -dao \*.cdr | tee  burnfile.sh
chmod 700 burnfile.sh

