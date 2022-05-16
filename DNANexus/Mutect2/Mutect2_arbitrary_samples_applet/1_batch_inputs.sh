echo "Usage: ./1_batch_inputs.sh [DNANexus path to files] [Number of files to prepare]"

# Check number of cram and crai files.
wc -l ../Mutect2_50_samples_applet/all_cram_input_file.txt
wc -l ../Mutect2_50_samples_applet/all_crai_input_file.txt

# Prepare the last x samples that were not divisible by 50 from mutect2_50_samples_orientation.
NUM=$1
echo "Preparing "${NUM}" samples."
tail -n "${NUM}" ../Mutect2_50_samples_applet/all_cram_input_file.txt > cram_input_file.txt
tail -n "${NUM}" ../Mutect2_50_samples_applet/all_crai_input_file.txt > crai_input_file.txt
wc -l cram_input_file.txt
wc -l crai_input_file.txt

echo "Remember: Modify workflow_input.json with the correct variables before running 2_batch_script.sh"

# ---Documentation---
# Testing 100 jobs that run 51 samples each.
#head -n 5100 all_cram_input_file.txt > cram_input_file.txt
#head -n 5100 all_crai_input_file.txt > crai_input_file.txt
#wc -l cram_input_file.txt
#wc -l crai_input_file.txt
