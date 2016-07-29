#!/bin/bash

OPT_DIR=$HOME/opt
declare -a imp=("1.10.3" "2.0.0" "master")

for MPI in "${imp[@]}"
do

	rm $OPT_DIR/mpi
	ln -s $OPT_DIR/ompi/$MPI/fast $OPT_DIR/mpi

	echo "Created new MPI symbol for $OPT_DIR/ompi/$MPI/fast"

	make clean >/dev/null
	make > /dev/null
	echo "Recompiled the benchmark, start testing ..."
	let "pow = 1";

	for i in {1..20};
	do
		let "pow*=2"
		mpirun -np 2 -mca btl vader,self -mca pml ob1 --bind-to socket ./mr_th_nb -s $pow -S -t $1 -b >> $MPI.$1t.finebinding.result

	done
done
