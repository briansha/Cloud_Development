# Mutect2

This repository will detail the implementation of an applet that runs an arbitrary number of samples per job. Note that more than 1000 samples per job is currently not supported.

This repository details the creation of an applet on DNANexus for Mutect2.

### Special Notes
Since the Splitintervals task is not being used - notes regarding the -L parameter from the Mutect2 command that is present in the M2 task:
- Instead of using the Splitintervals task and feeding it an interval list, we are instead feeding it the .bed file that would normally be fed into the Splitintervals task.

### Cloud Computing Optimization
- * Lots to fill out in this section still *
- Instance type - this is the most important - mem3_ssd1_v2_x2 is the cheapest per hour at 0.0132 euros, 2 CPU, 16 GB memory, and 75 GB storage. Since this should (almost) always be used, you should not try to run more than 60 samples per job (since each cram file is around 1 GB and the instance is limited to 75 GB of storage).

## Batch Executions

### Option 1: Generate Batch TSV Files
- Note: This method is only effective at running jobs where one sample is to be processed. It cannot run large sample sets effectively. (Even when re-organizing the tsv files to be [file,file,file...] so that multiple samples are sent to array variables...you will run into an error that prevents you from submitting a TSV file with too many characters per row.)
- dxpy.exceptions.InvalidInput: Expected key "properties.batch-id" of input to be no longer than 700 UTF-8 encoded bytes, code 422. Request Time=1641366069.1002839, Request ID=1641366069306-846581
- If you do want to use this to run jobs one sample at a time....note the following below.
- -imutect2_tumor_reads:
- * "-i" = "--input"
- * "mutect2_tumor_reads": This is the variable for the tumor reads that is normally present in the workflow_input.json file.
```
dx generate_batch_inputs --path Bulk/'Exome sequences'/'Exome OQFE CRAM files - interim 200k release'/10/ \
-imutect2_tumor_reads="(.*)\.cram$" \
-imutect2_tumor_reads_index="(.*)\.cram.crai$"
```

### Running a Batch Execution on a Batch TSV File
- You will need to remove any input to mutect2_tumor_reads and mutect2_tumor_reads_index seen in the workflow_input.json file.
- Input to these two variables is read from a batch.tsv file - each row and the corresponding column name and will be unique for each job.
- Number of jobs submitted will equal the number of rows the batch.tsv file contains.
- Below, the workflow_input.json file is still used, so each job will have values to input variables seen within this file. What will be unique to each job will be the input to the mutect2_tumor_reads and mutect2_tumor_reads_index seen within each row in the batch.tsv file.
```
dx run applet-id \
--input-json-file workflow_input.json \
--priority normal \
-y \
--destination "project-name":/mutect2_workflow_test \
--instance-type mem3_ssd1_v2_x2 \
--batch-tsv dx_batch.0000.tsv
```

### Option 2: Batch Preparation for Large Sample Sets
- https://dnanexus.gitbook.io/uk-biobank-rap/science-corner/guide-to-analyzing-large-sample-sets
- Build the applet.
```
dx build mutect_arbitrary_samples_orientation --destination "project-name":/workflows/mutect2/ --overwrite
```
- Grab the number of samples you'd like (check batch_inputs.sh if you need to edit)
```
chmod 700 batch_inputs.sh
./batch_inputs.sh
```
- Prepare all of the dx run commands
- Order of arguments to the python script: applet id, batch size, instance type, destination folder.
```
python3 batch_script.py applet-id 50 "project-name":/mutect2_workflow_test/50_samples_per_job_test > submission_command.txt
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
dx build mutect_arbitrary_samples_orientation --destination "project-name":/workflows/mutect2/ --overwrite
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
--destination "project-name":/mutect2_workflow_test \
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
