#!/bin/sh
NAME=${NAME:=$1}
NAME=${NAME:=default}
BLOCKSIZES="4k 8k 16k 32k 128k 1m"
LOOPS="01 02 03 04 05"
JOBS="1 2 4 8"
LOOPS="01 02 "
JOBS="4 "
SIZE=2
RUNTIME=120
echo "Starting run..."
mkdir ./${NAME}
for b in $BLOCKSIZES; do
	rm -rf /persist/fio
	mkdir -p /persist/fio/$b
	time sync
	# Do Allocation
	fio --directory=/persist/fio/$b --name=bench_$b --rw=write --bs=$b --iodepth=16 --size=${SIZE}G --end_fsync=1 --ioengine=psync --group_reporting --fallocate=none --io_size=${SIZE}G
	time sync
	time sync
	# Do runs
	for j in $JOBS; do
		for r in $LOOPS; do
                        fio --directory=/persist/fio/$b --name=bench_$b --rw=randread --bs=$b --numjobs=${j} --iodepth=16 --size=${SIZE}G --end_fsync=1 --ioengine=psync --group_reporting --fallocate=none --runtime=$RUNTIME --time_based --output-format=json >> ./${NAME}/read_${b}_${j}_${r}.json
                        fio --directory=/persist/fio/$b --name=bench_$b --rw=randwrite --bs=$b --numjobs=${j} --iodepth=16 --size=${SIZE}G --end_fsync=1 --ioengine=psync --group_reporting --fallocate=none --runtime=$RUNTIME --time_based --output-format=json >> ./${NAME}/write_${b}_${j}_${r}.json
                        time sync
                done
                jq '.jobs[0].read.bw' ./${NAME}/read_${b}_${j}_*.json > ./${NAME}/read_bw_summary_${b}_${j}.txt
                jq '.jobs[0].read.iops' ./${NAME}/read_${b}_${j}_*.json > ./${NAME}/read_iops_summary_${b}_${j}.txt
                jq '.jobs[0].write.bw' ./${NAME}/write_${b}_${j}_*.json > ./${NAME}/write_bw_summary_${b}_${j}.txt
                jq '.jobs[0].write.iops' ./${NAME}/write_${b}_${j}_*.json > ./${NAME}/write_iops_summary_${b}_${j}.txt
	done
done
