# Mutect2
This repository will detail the implementation of an applet on DNANexus that runs 50 samples per job using Mutect2.

## Tutorial
- Use 0_build_applet.sh, 1_batch_inputs.sh, 2_batch_script.sh, and 3_submission_script.sh in order to submit batch executions.
- Modify workflow_input.json with correct variables before running batch_script.py
- Important: "null.txt" - This is a dummy file that can have anything in it, such as "Dummy File". But, it must be named "null.txt". This file must be assigned to any file variable located in mutect_50_samples_orientation/dxapp.json (such as the "m2_extra_args_files" variable) if you do not want that parameter to be used in the analysis. You will need to assign the project ID and the file ID for "null.txt" to the appropriate file variables in the workflow_input.json file.



### Special Notes
Since the Splitintervals task is not being used - notes regarding the -L parameter from the Mutect2 command that is present in the M2 task:
- Instead of using the Splitintervals task and feeding it an interval list, we are instead feeding it the .bed file that would normally be fed into the Splitintervals task.

### Cloud Computing Optimization
- * Lots to fill out in this section still *
- Instance type - this is the most important - mem3_ssd1_v2_x2 is the cheapest per hour at 0.0132 euros, 2 CPU, 16 GB memory, and 75 GB storage.

## Batch Executions

### Best option: Batch Preparation for Large Sample Sets
- https://dnanexus.gitbook.io/uk-biobank-rap/science-corner/guide-to-analyzing-large-sample-sets
- Login to DNANexus
```
dx login
```

- Build the applet.
```
dx build mutect_50_samples_orientation --destination "App 43397 - Bicklab & TBIlab":/workflows/mutect2/ --overwrite
```
- Grab the number of samples you'd like (check batch_inputs.sh if you need to edit)
```
chmod 700 batch_inputs.sh
./batch_inputs.sh
```
- Prepare all of the dx run commands
- Order of arguments to the python script: applet id, batch size, instance type, destination folder.
```
python3 batch_script.py applet-G7FgP08JVGgfBX6g9YF8gkX4 50 "App 43397 - Bicklab & TBIlab":/mutect2_workflow_test/50_samples_per_job_test > submission_command.txt
```
- Check the first command
```
head -1 submission_command.txt
```
- Run the first command to check for errors
```
head -1 submission_command.txt | sh
```
- Launch remaining jobs
- This would generate submission_command_newaa, submission_command_newab, submission_command_newac, submission_command_newad. Then the user can submit each split file using the command.
```
tail -n +2 submission_command.txt > submission_command_remainder.txt
split -500 submission_command_remainder.txt submission_command_new
sh submission_command_newaa
sh submission_command_newab
sh submission_command_newac
sh submission_command_newad
```

### Limitations on Batch Executions:
- Hard limit of 100 concurrent workers per user. Extra jobs are placed in a job queue.

## Single Jobs

### Building the app:
- The applet ID is generated once finished.
```
dx build mutect_arbitrary_samples_orientation --destination "App 43397 - Bicklab & TBIlab":/workflows/mutect2/ --overwrite
```

### Finding Stage IDs and Input Names:
- Replace <applet_id> with the ID of the applet.
```
dx run <applet_id> --help
```

### List Available Instance Types:
```
dx run --instance-type-help
```

### Running a Job in Interactive Mode with the CLI:
- Replace inputs in workflow_input.json with file IDs in DNANexus as necessary.
- Replace <applet_id> with the ID of the applet.
```
dx run <applet_id> \
--input-json-file workflow_input.json \
--priority normal \
-y \
--destination "App 43397 - Bicklab & TBIlab":/mutect2_workflow_test \
--instance-type mem3_ssd1_v2_x2
```

### Job Monitoring
- This shows a log of job execution in real-time.
- However, it is unreliable and has frequently not shown the full contents of the log file (the log file on DNANexus under the "Monitoring" tab is much more reliable).
```
dx watch <job_id>
```

## Optional Variables
- Making variables optional in Bash requires a lot more effort than in WDL. Therefore, "if, then" statements will be utilized sparingly as the need arises around the usage of certain variables.
- To be efficient, the bare-bones needed parameters that are necessary to meet our needs will be coded in first (based off the mutect2.wdl and a previous successful run in Terra).

## Issues
- Attempts at passing strings with spaces in them into a Docker image as a single argument result in issues.
- Example - mutect2_m2_extra_args: '--downsampling-stride 20 --max-reads-per-alignment-start 6 --max-suspicious-reads-per-alignment-start 6 -alleles'

![issues](issues/issue1.png)


## Resources:

- [Intro to Building Apps](https://documentation.dnanexus.com/developer/apps/intro-to-building-apps)
- [Running Apps and Applets](https://documentation.dnanexus.com/user/running-apps-and-workflows/running-apps-and-applets)
- [dxapp.json Metadata](https://documentation.dnanexus.com/developer/apps/app-metadata)
- [DNANexus Talk on Apps, Applets, and Workflows](https://www.youtube.com/watch?v=U8QZAGwnUm0)(28:53 - Limitations on Batch Executions)
