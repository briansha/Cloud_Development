# Grab a few samples
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/10/ --name "*.cram" --delim > cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/11/ --name "*.cram" --delim >> cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/10/ --name "*.cram.crai" --delim > crai_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/11/ --name "*.cram.crai" --delim >> crai_input_file.txt
#wc -l cram_input_file.txt
#wc -l crai_input_file.txt

# Grab all 200K samples.
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram" --delim > all_cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram.crai" --delim > all_crai_input_file.txt
#sort -k 4 -t$'\t' all_cram_input_file.txt > crams_input_file.txt
#sort -k 4 -t$'\t' all_crai_input_file.txt > crais_input_file.txt
#mv crams_input_file.txt all_cram_input_file.txt
#mv crais_input_file.txt all_crai_input_file.txt
wc -l all_cram_input_file.txt
wc -l all_crai_input_file.txt

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

# The first 200000
head -n 200000 all_cram_input_file.txt > cram_input_file.txt
head -n 200000 all_crai_input_file.txt > crai_input_file.txt
wc -l cram_input_file.txt
wc -l crai_input_file.txt

# Split into several submission scripts
#split -1000 submission_command.txt submission_command_new
#sh submission_command_newaa
