#!/bin/bash
 
cutoffs="100 200 300 400 500 600 700 800 900 1000 1100 1200"
 
template_file=input_H2O_temp.inp
input_file=input.inp

rel_cutoff=60
 
for ii in $cutoffs ; do
    work_dir=cutoff_${ii}Ry
    if [ ! -d $work_dir ] ; then
        mkdir $work_dir
    else
        rm -r $work_dir/*
    fi
    sed -e "s/relcutoff_val/${rel_cutoff}/g" \
        -e "s/cutoff_val/${ii}/g" \
    $template_file > $work_dir/$input_file
done

