echo "Split into several submission scripts with up to 1000 lines per script. Each line correlates to one job submission that will run 50 samples."
echo "To run one job: head -1 submission_command.txt | sh"
echo "To run set of jobs: sh submission_command_newaa"
echo "Note: May want to open multiple terminals and type 'sh submission_command_newxx'"
split -1000 submission_command.txt submission_command_new
