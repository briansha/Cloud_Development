# Grab a few samples
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/10/ --name "*.cram" --delim > cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/11/ --name "*.cram" --delim >> cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/10/ --name "*.cram.crai" --delim > crai_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/11/ --name "*.cram.crai" --delim >> crai_input_file.txt

# Grab all 200K samples.
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram" --delim > all_cram_input_file.txt
#dx find data --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release' --name "*.cram.crai" --delim > all_crai_input_file.txt
#sort -k 4 -t$'\t' all_cram_input_file.txt > crams_input_file.txt
#sort -k 4 -t$'\t' all_crai_input_file.txt > crais_input_file.txt
#mv crams_input_file.txt all_cram_input_file.txt
#mv crais_input_file.txt all_crai_input_file.txt
wc -l all_cram_input_file.txt
wc -l all_crai_input_file.txt

# Testing 100 jobs that run 51 samples each.
#head -n 5100 all_cram_input_file.txt > cram_input_file.txt
#head -n 5100 all_crai_input_file.txt > crai_input_file.txt
#wc -l cram_input_file.txt
#wc -l crai_input_file.txt

# Grab the last 604 samples.
tail -n 604 all_cram_input_file.txt > cram_input_file.txt
tail -n 604 all_crai_input_file.txt > crai_input_file.txt
wc -l cram_input_file.txt
wc -l crai_input_file.txt
