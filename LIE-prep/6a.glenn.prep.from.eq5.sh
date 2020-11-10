#!/bin/bash 

# By Yasmin 2009

# This script creates input-files for the water and protein runs. Then it creates the job-files and orders everything into their respective directories.

# CHANGELOG:
# 2013-01-03: MAJOR CHANGE Added options for different dockingprograms and random seeds
# 2013-03-04: Changed how the input file is generated

#--------------------- VARIABLES (CHANGE BETWEEN RUNS --------#

# projname=snic002-12-26
# projname=snic001-11-250
# projname=snic025-12-10
 projname=SNIC2013-26-1

# walltime=13:00:00 runtime=250000 # 2.5ns collection (4000 steps/min in 20A sphere)
# walltime=11:00:00 runtime=200000 # 2ns collection (4000 steps/min in 20A sphere)
# walltime=19:00:00 runtime=400000 # 4ns collection (4000 steps/min in 20A sphere)
# walltime=23:00:00 runtime=500000 # 5ns collection (4000 steps/min in 20A sphere)
 walltime=26:00:00 runtime=500000 # 2ns eq, 10ns collection, 2fs timestep (4000 steps/min in 20A sphere)
# walltime=46:00:00 runtime=1000000 # 10ns collection (4000 steps/min in 20A sphere)
# walltime=55:00:00 runtime=12500000 # 12.5ns collection (4000 steps/min in 20A sphere)
# walltime=70:00:00 runtime=15000000 # 15ns collection (4000 steps/min in 20A sphere)

 protein=Q.hCOX1L

 dockingprogram=MAN
# dockingprogram=ASP
# dockingprogram=CHEM
# dockingprogram=GOLD
# dockingprogram=PLP
# dockingprogram=GSP
# dockingprogram=GXP
# dockingprogram=XRAY

 date=140707
# date=$( date +%y%m%d)


# seed=s1 seed1=10 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80
# seed=s2 seed1=50 seed2=60 seed3=70 seed4=80 seed10=15 seed20=25 seed30=35 seed40=45
# seed=s3 seed1=15 seed2=25 seed3=35 seed4=45 seed10=55 seed20=65 seed30=75 seed40=85
# seed=s4 seed1=55 seed2=65 seed3=75 seed4=85 seed10=17 seed20=32 seed30=43 seed40=58
# seed=s5 seed1=17 seed2=32 seed3=43 seed4=58 seed10=10 seed20=20 seed30=30 seed40=40
 seed=s6 seed1=12 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80
# seed=s7 seed1=20 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80
# seed=s8 seed1=68 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80
# seed=s9 seed1=73 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80
# seed=s10 seed1=2 seed2=20 seed3=30 seed4=40 seed10=50 seed20=60 seed30=70 seed40=80

 mpi=mpirun  Qdyn5p=/c3se/users/yasmink/Glenn/Qdyn5p

#---------------END OF VARIABLES SECTION- NO MORE EDITING! -----#

 cp -r $date.$protein.$dockingprogram $date.$protein.$dockingprogram.$seed
 cd $date.$protein.$dockingprogram.$seed

 for i in *.fep
 do
 ligname=$( echo "$i" | sed -e 's/\.fep//g')
 mkdir $ligname
 mkdir $ligname/Protein
 mkdir $ligname/Water
 cp ../Protein/*.inp $ligname/Protein/
 cp ../Water/*.inp $ligname/Water/

 sed -i "s|LIG|$ligname|g" $ligname/Protein/*.inp
 sed -i "s|lig|$ligname|g" $ligname/Water/*.inp

 awk '{print $1}' $ligname.fep > ATOMNO.tmp
 tail -1 ATOMNO.tmp > lastno.tmp
 lastno=$( tail lastno.tmp)
 proteinsize=$( tail $ligname.prot.lastno)
 atomno=$(echo $(($proteinsize + $lastno)))

 sed -i "s/1 8911 /1 $atomno /g" $ligname/Protein/*.inp
 sed -i "s/1 20 /1 $lastno /g" $ligname/Water/*.inp
 sed -i "s/50000/$runtime/g" $ligname/Protein/md*.inp

 sed -i "s/10/$seed1/g" $ligname/Protein/eq1.inp
 sed -i "s/20/$seed2/g" $ligname/Protein/eq2.inp
 sed -i "s/30/$seed3/g" $ligname/Protein/eq3.inp
 sed -i "s/40/$seed4/g" $ligname/Protein/eq4.inp

 sed -i "s/14/$seed1/g" $ligname/Water/eq1.inp


 rm *.tmp
 mv $ligname.* $ligname/

# Create job-files

 echo -e "#!/bin/bash" > $ligname/Protein/$date.prot.$ligname.job
 echo -e "#SBATCH -N 1 -n 16" >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "#SBATCH -A $projname" >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "#SBATCH -p glenn" >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "#SBATCH -t $walltime" >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "#SBATCH -J $ligname"'\n' >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "job=prot$date$ligname"'\n' >> $ligname/Protein/$date.prot.$ligname.job
 echo -e 'mkdir "${job}"''\n' >> $ligname/Protein/$date.prot.$ligname.job
 echo -e "module load openmpi"'\n' >> $ligname/Protein/$date.prot.$ligname.job

# for i in {1..5}
# do
        echo -e "$mpi $Qdyn5p eq5.inp >"' ${job}/'"eq5.log" >> $ligname/Protein/$date.prot.$ligname.job
#done

 for i in {1..10}
 do
        echo -e "$mpi $Qdyn5p md$i.inp >"' ${job}/'"md$i.log" >> $ligname/Protein/$date.prot.$ligname.job
 done

 echo -e '\n'"# End of script" >> $ligname/Protein/$date.prot.$ligname.job

 wait
 done


# ZIP the contents 

 cd /home/yasmin/COX-2/
# tar -cvzf $date.$protein.$dockingprogram.$seed.tar $date.$protein.$dockingprogram.$seed/

# DONE :)
