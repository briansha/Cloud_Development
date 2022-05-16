echo "Usage: ./batch_inputs.sh [DNANexus path to files] [Number of files to prepare]"

# Grab x samples from DNANexus destination path.
DESTINATION=$1
dx find data --path "${DESTINATION}" --name "*.cram" --delim > all_cram_input_file.txt
dx find data --path "${DESTINATION}" --name "*.cram.crai" --delim > all_crai_input_file.txt
sort -k 4 -t$'\t' all_cram_input_file.txt > crams_input_file.txt
sort -k 4 -t$'\t' all_crai_input_file.txt > crais_input_file.txt
mv crams_input_file.txt all_cram_input_file.txt
mv crais_input_file.txt all_crai_input_file.txt
wc -l all_cram_input_file.txt
wc -l all_crai_input_file.txt

# Prepare x samples.
NUM=$2
echo "Preparing "${NUM}" samples."
head -n "${NUM}" all_cram_input_file.txt > cram_input_file.txt
head -n "${NUM}" all_crai_input_file.txt > crai_input_file.txt
wc -l cram_input_file.txt
wc -l crai_input_file.txt

echo "Remember: Modify workflow_input.json with the correct variables before running 2_batch_script.sh"


# ---Documentation---
# Grab all 200K samples.
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram" --delim > all_cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram.crai" --delim > all_crai_input_file.txt
#sort -k 4 -t$'\t' all_cram_input_file.txt > crams_input_file.txt
#sort -k 4 -t$'\t' all_crai_input_file.txt > crais_input_file.txt
#mv crams_input_file.txt all_cram_input_file.txt
#mv crais_input_file.txt all_crai_input_file.txt
#wc -l all_cram_input_file.txt
#wc -l all_crai_input_file.txt

# Testing 100 jobs that run 50 samples each
# Have to sort them so the index file corresponds to the cram file.
# Can do reverse sorting with "-r".
#sort -k 4 -t$'\t' all_cram_input_file.txt > crams_input_file.txt
#sort -k 4 -t$'\t' all_crai_input_file.txt > crais_input_file.txt
#mv crams_input_file.txt all_cram_input_file.txt
#mv crais_input_file.txt all_crai_input_file.txt
#head -n 5000 all_cram_input_file.txt > cram_input_file.txt
#head -n 5000 all_crai_input_file.txt > crai_input_file.txt
#wc -l cram_input_file.txt
#wc -l crai_input_file.txt
