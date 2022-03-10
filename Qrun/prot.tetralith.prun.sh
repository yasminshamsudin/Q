#!/bin/bash 

# By Yasmin 2022-03-09
# Adapted from corresponding scripts on Rackham.

# This script creates input-files for the protein runs and submits the calculations on Tetralith (NSC).

#--------------------- VARIABLES (CHANGE BETWEEN RUNS --------#
# System specific
# date=$( date +%y%m%d)
 date=220308
 protein=TEM1
 run=5      # Simulation time in ns

# User specific
projstorename=snic2021-6-309
projrunname=snic2021-5-520
user=x_yaskh

# Cluster specific
projhome=/proj/$projstorename/users/$user
qdyn5p=/home/x_yaskh/Q/qsource/bin/Qdyn5p
mpi=mpprun

#---------------END OF VARIABLES SECTION- NO MORE EDITING! -----#
wdir=$(pwd)

cd $date.$protein
        
for seed in {1..5}
    do

    for fep in *.fep
        do

        # General edits in input files tailored to ligand and protein
        ligname=$( echo "$fep" | sed -e 's/\.fep//g')

        cp -r $projhome/Q/Protein .

        awk '{print $1}' $fep > ATOMNO.tmp
        tail -1 ATOMNO.tmp > lastno.tmp
        lastno=$( tail lastno.tmp)
        proteinsize=$( tail $ligname.prot.lastno)
        atomno=$(echo $(($proteinsize + $lastno)))

        rm *.tmp

        runtime=$((50000 * $run))
        sed -i "s/1 8911 /1 $atomno /g" Protein/*.inp
        sed -i "s/500000/$runtime/g" Protein/md*.inp

        sed -i "s|LIG.fep|$fep|g" Protein/*.inp

        # Specific for two (or more) different charge schemes (CM1A, OPLS2005, RESP)
        for n in $ligname.*.protein.top
        do
            charge=$( echo "$n" | sed -e 's/\.protein.top//g')

            mkdir $charge.prot$seed
            cp -r Protein $charge.prot$seed/

            sed -i "s|LIG.protein.top|$n|g" $charge.prot$seed/Protein/*.inp
            randomseed=$(($RANDOM%1200))
            sed -i "s/xxx/$randomseed/g" $charge.prot$seed/Protein/eq1.inp



            # Create job-files

            cd $charge.prot$seed/

            walltime=$((4 * $run))
            echo -e "#!/bin/bash" > $date.$ligname.job
            echo -e "#SBATCH -N 1" >> $date.$ligname.job
            echo -e "#SBATCH --ntasks-per-node=16" >> $date.$ligname.job
            echo -e "#SBATCH -A $projrunname" >> $date.$ligname.job
            echo -e "#SBATCH -t $walltime:00:00" >> $date.$ligname.job
            echo -e "#SBATCH -J $ligname-$protein"'\n' >> $date.$ligname.job

            echo -e "$mpi $qdyn5p Protein/eq1.inp > eq1.log" >> $date.$ligname.job

            for i in {2..5}
            do
                echo -e "$mpi $qdyn5p Protein/eq$i.inp > eq$i.log" >> $date.$ligname.job
            done

            for i in {1..10}
            do
                echo -e "$mpi $qdyn5p Protein/md$i.inp > md$i.log" >> $date.$ligname.job
            done

            echo -e '\n'"# End of script" >> $date.$ligname.job

            sbatch $date.$ligname.job
            cd ..
            wait
        done
    done

done

# DONE :)