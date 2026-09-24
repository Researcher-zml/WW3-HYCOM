#!/bin/csh
#SBATCH -J WW3_SCS
#SBATCH -N 1
#SBATCH -n 32

cd /public5/home/t6s007154/WW3/SCS/work

mpirun -np 32 /public5/home/t6s007154/WW3/model/exe/ww3_shel >& ww3_shel.log








