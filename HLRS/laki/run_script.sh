#!/bin/bash
#PBS -l nodes=1:hsw:ppn=20
#PBS -lwalltime=24:00:00
#PBS -m abe
#PBS -M niethammer@hlrs.de


cd /zhome/academic/rus/hpc/chris/bench

declare -a modules=("1.10.3-mt-gnu-6.1.0" "2.0.0-mt-gnu-6.1.0" "2.0.1rc1-gnu-6.1.0" "master-gnu-6.1.0")

#nt=$1
#nd=${nt:=nothreads}
for nt in 0 1 2 4
do
    for module in "${modules[@]}"
    do

        echo "Benchmarking Open MPI $module"
        module purge
        module load unsupported-modules
        module load mpi/openmpi/$module

        resultfile=$module.${nt}-threads.result
        rm -f $resultfile

        make clean >/dev/null
        make > /dev/null
        echo "Recompiled the benchmark, start testing ..."
        let "pow = 1";

        for i in {1..20};
        do
            let "pow*=2"
            if [ $nt -eq 0 ] ; then
                cmd="mpirun -np 2 -mca btl vader,self -mca pml ob1 --bind-to socket ./mr_th_nb -s $pow -S -Dthrds"
            else
                cmd="mpirun -np 2 -mca btl vader,self -mca pml ob1 --bind-to socket ./mr_th_nb -s $pow -S -t $nt" 
            fi
            echo $cmd
            $cmd >> $resultfile
        done
        module rm $module
    done
done
