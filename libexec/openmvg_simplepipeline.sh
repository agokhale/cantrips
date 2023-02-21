#!/bin/sh -xe 
#cribbed from https://github.com/openMVG/openMVG/blob/develop/src/software/SfM/SfM_GlobalPipeline.py.in
imgdir=$1
outdir=$2

matchd="$outdir/match_hop"
featd="$outdir/feature_hop"
recond="$outdir/reconstruction_hop"
alld="$matchd $featd $recond"
camdb=/usr/local/share/openMVG/sensor_width_camera_database.txt
mkdir -p $outdir
mkdir -p $alld

openMVG_main_SfMInit_ImageListing -i $imgdir -o $matchd -d $camdb #generates sfm_data.json
sfmdata="$matchd/sfm_data.json"
openMVG_main_ComputeFeatures -i $sfmdata -o $matchd -m SIFT
openMVG_main_PairGenerator -i $sfmdata -o ${matchd}/pairs.bin
openMVG_main_ComputeMatches -i $sfmdata -p ${matchd}/pairs.bin -o $matchd/matches.putative.bin
openMVG_main_GeometricFilter -i $sfmdata  -m $matchd/matches.putative.bin -g e -o $matchd/matches.e.bin
openMVG_main_SfM --sfm_engine GLOBAL --input_file  $sfmdata --match_file ${matchd}/matches.e.bin --output_dir $recond
openMVG_main_ComputeStructureFromKnownPoses -i ${recond}/sfm_data.bin -m $matchd -f $matchd/matches.e.bin -o $recond/robust.bin
openMVG_main_ComputeSfM_DataColor -i ${recond}/sfm_data.bin -o ${recond}/colorized.ply


