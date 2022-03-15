# Mutect2

This repository details the creation of an applet on DNANexus for Mutect2.

## Current Work
- Mutect2_arbitrary_samples_applet: This directory contains work on turning the mutect2.wdl into a single applet on DNANexus. This directory will run an arbitrary number of samples per job submission and contain the most information on the README.
- Mutect2_50_samples_applet: This directory will run 50 samples per job submission.

## Note
- If dxCompiler works (from DNANexus) - these applets won't have to be written by hand.
- Everywhere "applet-id", "project-id", and "project-name" is seen - this will be replaced with the actual corresponding applet, project ID, or project name.
