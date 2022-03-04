#!/bin/bash 

# By Yasmin 2022-03-03

# This script creates input-files for the water runs and submits the calculations.

#--------------------- VARIABLES (CHANGE BETWEEN RUNS --------#
# System specific
# date=$( date +%y%m%d)
 date=220218
 protein=Q.TEM1
 run=5      # Simulation time in ns

# Cluster specific
projname=snic2022-22-61
projhome=/proj/$projname
qdyn5p=$projhome/Q/qdyn5p
mpi=mpirun

#---------------END OF VARIABLES SECTION- NO MORE EDITING! -----#
wdir=$(pwd)

cd $date.$protein

for seed in {1..5}
    do

    for i in *.fep
        do
        ligname=$( echo "$i" | sed -e 's/\.fep//g')

        cp -r $projhome/Q/Protein .

        sed -i "s|LIG|$ligname|g" Protein/*.inp

        awk '{print $1}' $ligname.fep > ATOMNO.tmp
        tail -1 ATOMNO.tmp > lastno.tmp
        lastno=$( tail lastno.tmp)
        proteinsize=$( tail $ligname.prot.lastno)
        atomno=$(echo $(($proteinsize + $lastno)))

        runtime=$((50000 * $run))
        sed -i "s/1 8911 /1 $atomno /g" Protein/*.inp
        sed -i "s/500000/$runtime/g" Protein/md*.inp

        mkdir prot$seed
        cp Protein/eq1.inp prot$seed

        randomseed=$(($RANDOM%1200))
        sed -i "s/xxx/$randomseed/g" prot$seed/eq1.inp

        rm *.tmp

        # Create job-files

        cd prot$seed/

        walltime=$((4 * $run))
        echo -e "#!/bin/bash" > $date.$ligname.job
        echo -e "#SBATCH -N 1 -n 16" >> $date.$ligname.job
        echo -e "#SBATCH -A $projname" >> $date.$ligname.job
        echo -e "#SBATCH -t $walltime:00:00" >> $date.$ligname.job
        echo -e "#SBATCH -J $ligname-$protein"'\n' >> $date.$ligname.job

        echo -e "module load intel/17.2 openmpi/2.1.0"'\n' >> $date.$ligname.job
        echo -e "$mpi $qdyn5p eq1.inp > eq1.log" >> $date.$ligname.job

        for i in {2..5}
        do
            echo -e "$mpi $qdyn5p ../Protein/eq$i.inp > eq$i.log" >> $date.$ligname.job
        done

        for i in {1..10}
        do
            echo -e "$mpi $qdyn5p ../Protein/md$i.inp > md$i.log" >> $date.$ligname.job
        done

        echo -e '\n'"# End of script" >> $date.$ligname.job

        sbatch $date.$ligname.job
        cd ..
        wait

    done

    
done

# DONE :)
