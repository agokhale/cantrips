#!/bin/sh -xe 
imgdir=$1
outdir=$2

matchd="$outdir/match_hop"
featd="$outdir/feature_hop"
recond="$outdir/reconstruction_hop"
alld="$matchd $featd $recond"
camdb=/usr/local/share/openMVG/sensor_width_camera_database.txt
mkdir -p $alld

openMVG_main_SfMInit_ImageListing -i $imgdir -o $matchd -d $camdb #generates sfm_data.json
sfmdata="$matchd/sfm_data.json"
ls -l $sfmdata
openMVG_main_ComputeFeatures -i $sfmdata -o $matchd -m SIFT
ls -lrt $featd
openMVG_main_ComputeMatches -i $sfmdata -o $matchd
ls -lrt $matchd
openMVG_main_IncrementalSfM -i $sfmdata -m $matchd -o $recond
sfmdatabin="$recond/sfm_data.bin"
ls -l $sfmdatabin
openMVG_main_ComputeSfM_DataColor -i $sfmdatabin -o $recond/colorized.ply
colrply="$recond/colorized.ply"
ls -l $colrply
openMVG_main_ComputeStructureFromKnownPoses -i $sfmdatabin -m $matchd -f $matchd/matches.f.bin -o $recond/robust.bin
ls -l $recond/robust.bin
openMVG_main_ComputeSfM_DataColor -i $recond/robust.bin -o $recond/robust_colorized.ply


