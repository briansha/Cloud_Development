#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Use this script with batch_inputs.sh
import sys
import math

cram_input_file="cram_input_file.txt"
crai_input_file="crai_input_file.txt"
batch_size=int(50)

# Only these variables need changed per script execution.
applet_id=sys.argv[1]            # applet-id
instance_type=sys.argv[2]        # mem3_ssd1_v2_x2
destination=sys.argv[3]          # workflow_submissions/mutect2/TODAYSDATE
batch_execution_tag=sys.argv[4]  # 200K_exome

def _parse_dx_delim(delim_line):
    '''parse each list of delim output from dx find into NAME, ID, SIZE, and FOLDER'''
    id=delim_line[-1]
    split_path=delim_line[3].split('/')
    folder='/'+'/'.join(split_path[:-1])
    name=split_path[-1]
    #folder and name is not used in this example, but they can be useful for some scenerio

    return name,id,folder

fd_cram=open(cram_input_file)
cram_lines=fd_cram.readlines()
fd_crai=open(crai_input_file)
crai_lines=fd_crai.readlines()

sample_number=len(cram_lines)
batch_mapped_files_cram=''
batch_mapped_files_crai=''
input_number=0
job_number=1
number_of_batch = int(math.ceil(sample_number*1.0/batch_size))
for batch_number in range(number_of_batch):
    batch_mapped_files_cram=''
    batch_mapped_files_crai=''
    for member in range(batch_size):
        # Cram files
        delim_line = cram_lines[input_number].strip().split('\t')
        name, id, folder = _parse_dx_delim(delim_line)
        batch_mapped_files_cram += '-imutect2_tumor_reads={} '.format(id)
        #input_number+=1

        # Crai files
        delim_line = crai_lines[input_number].strip().split('\t')
        name, id, folder = _parse_dx_delim(delim_line)
        batch_mapped_files_crai += '-imutect2_tumor_reads_index={} '.format(id)
        input_number+=1
        final_folder = destination + "/" + str(batch_number)

        if input_number == sample_number:
            break

    # Introducing delay for so submissions are not throttled by DNANexus.
    if (job_number % 5 == 0):
        print('sleep 60')

    job_number += 1
    # Will want to change this print command to match your applet ID, etc.
    # I expect the number of cram files will not always be perfectly divisible by 100
    # or by how many samples you want per run. In that case, atleast one job will immediately fail.
    print('dx run {applet_id} --input-json-file workflow_input.json \
     {batch_mapped_files_cram} {batch_mapped_files_crai} --tag {batch_execution_tag} \
     --tag original --tag batch_n_{batch_number} \
     --destination "{final_folder}" \
     --priority normal --instance-type "{instance_type}" \
     -y --brief'.format(applet_id=applet_id,batch_mapped_files_cram=batch_mapped_files_cram,batch_mapped_files_crai=batch_mapped_files_crai,batch_execution_tag=batch_execution_tag,batch_number=batch_number,final_folder=final_folder,instance_type=instance_type))
