set -o pipefail
set -o errexit

# store arguments in a special array
args=("$@")
# get number of elements
ELEMENTS=${#args[@]}
# echo each element in array - for loop
for (( i=0;i<$ELEMENTS;i++)); do
    echo "Argument $((i+1)): ${args[${i}]}"
done

# ---------Required Inputs---------
# Mutect2
export mutect2_ref_dict="${1}"
export mutect2_ref_fai="${2}"
export mutect2_ref_fasta="${3}"
export mutect2_scatter_count="${4}"
export mutect2_tumor_reads="${71}"
export mutect2_tumor_reads_prefix="${72}"
export mutect2_tumor_reads_name="${73}"

# ---------Required Output---------
export filter_output_vcf="${74}"

# ---------Optional Inputs---------
# Mutect2
export mutect2_basic_bash_docker="${5}"
export mutect2_boot_disk_size="${6}"
export mutect2_compress_vcfs="${7}"
export mutect2_cram_to_bam_multiplier="${8}"
export mutect2_emergency_extra_disk="${9}"
export mutect2_filter_alignment_artifacts_mem="${10}"
export mutect2_filter_funcotations="${11}"
export mutect2_funco_annotation_defaults="${12}"
export mutect2_funco_annotation_overrides="${13}"
export mutect2_funco_compress="${14}"
export mutect2_funco_data_sources_tar_gz="${15}"
export mutect2_funco_default_output_format="${16}"
export mutect2_funco_filter_funcotations="${17}"
export mutect2_funco_output_format="${18}"
export mutect2_funco_reference_version="${19}"
export mutect2_funco_transcript_selection_list="${20}"
export mutect2_funco_transcript_selection_mode="${21}"
export mutect2_funco_use_gnomad_AF="${22}"
export mutect2_funcotator_excluded_fields="${23}"
export mutect2_funcotator_extra_args="${24}"
export mutect2_gatk_override="${25}"
export mutect2_getpileupsummaries_extra_args="${26}"
export mutect2_gga_vcf="${27}"
export mutect2_gga_vcf_idx="${28}"
export mutect2_gnomad="${29}"
export mutect2_gnomad_idx="${30}"
export mutect2_intervals="${31}"
export mutect2_large_input_to_output_multiplier="${32}"
export mutect2_learn_read_orientation_mem="${33}"
export mutect2_m2_extra_args="${34}"
export mutect2_m2_extra_filtering_args="${35}"
export mutect2_make_bamout="${36}"
export mutect2_max_retries="${37}"
export mutect2_normal_reads="${38}"
export mutect2_normal_reads_index="${39}"
export mutect2_pon="${40}"
export mutect2_pon_idx="${41}"
export mutect2_preemptible="${42}"
export mutect2_realignment_extra_args="${43}"
export mutect2_realignment_index_bundle="${44}"
export mutect2_run_funcotator="${45}"
export mutect2_run_orientation_bias_mixture_model_filter="${46}"
export mutect2_sequence_source="${47}"
export mutect2_sequencing_center="${48}"
export mutect2_small_input_to_output_multiplier="${49}"
export mutect2_small_task_cpu="${50}"
export mutect2_small_task_disk="${51}"
export mutect2_small_task_mem="${52}"
export mutect2_split_intervals_extra_args="${53}"
export mutect2_variants_for_contamination="${54}"
export mutect2_variants_for_contamination_idx="${55}"

# M2
export m2_cpu="${56}"
export m2_mem="${57}"
export m2_use_ssd="${58}"

# LearnReadOrientation

# CalculateContamination
export calculatecontamination_intervals="${59}"

# Filter

# FilterAlignmentArtifacts

# --------------Possible Task Optionals--------------
export mutect2_optionals="${60}"
export m2_extra_args_files="${61}"
export m2_extra_args_files_idx="${62}"
export calculatecontamination_optionals="${63}"
export filter_optionals="${64}"
export filteralignmentartifacts_optionals="${65}"

# --------------Specific Settings for each Task--------------
# Mutect2
export mutect2_normal_reads_prefix="${66}"
export mutect2_normal_reads_name="${67}"
export mutect2_command_mem="${68}"

# test
export splitintervals_interval_files="${69}"
export output_name="${70}"

if [ "$74" != "null" ]; then
    echo "Argument 74 is not null"
fi

if [ "$74" == "null" ]; then
    echo "Argument 74 is null"
fi

echo "Mutect tumor reads first element: ${mutect2_tumor_reads[0]}"
echo "Mutect tumor reads second element: ${mutect2_tumor_reads[1]}"
echo "Mutect tumor reads third element: ${mutect2_tumor_reads[2]}"
echo "filter_vcf first element: ${filter_output_vcf[0]}"
echo "filter_vcf reads second element: ${filter_output_vcf[1]}"
echo "filter_vcf reads third element: ${filter_output_vcf[2]}"

# Perform runs for x samples.
# Careful of for loops within for loops...don't want them both to be i=0 - that messes up the i.
# Use x=0 and i=0, for instance.

# See contents of null.txt
# - Also confirms the paths to these files are making it into the Docker container.
#cat ${mutect2_gga_vcf}

# ----------------------------------WORKFLOW----------------------------------
# ----------------------------Mutect2----------------------------
if [ "$mutect2_compress_vcfs" != "false" ]; then
    export mutect2_compress="true"
else
    export mutect2_compress="false"
fi
if [ "$mutect2_run_orientation_bias_mixture_model_filter" != "false" ]; then
    export mutect2_run_ob_filter="true"
else
    export mutect2_run_ob_filter="false"
fi
if [ "$mutect2_make_bamout" != "false" ]; then
    export mutect2_make_bamout_or_default="true"
else
    export mutect2_make_bamout_or_default="false"
fi
if [ "$mutect2_run_funcotator" != "false" ]; then
    export mutect2_run_funcotator_or_default="true"
else
    export mutect2_run_funcotator_or_default="false"
fi
if [ "$mutect2_filter_funcotations" != "true" ]; then
    export mutect2_filter_funcotations_or_default="false"
else
    export mutect2_filter_funcotations_or_default="true"
fi

export mutect2_output_basename="${mutect2_tumor_reads_prefix}"
export mutect2_unfiltered_name="${mutect2_output_basename}-unfiltered"
export mutect2_filtered_name="${mutect2_output_basename}-filtered"
export mutect2_funcotated_name="${mutect2_output_basename}-funcotated"
export mutect2_output_vcf_name="${mutect2_output_basename}.vcf"

# Basename
export mutect2_normal_reads_basename="`basename ${mutect2_normal_reads}`"
echo "mutect2_normal_reads_basename: ${mutect2_normal_reads_basename}"

if [ "$mutect2_normal_reads_basename" != "null.txt" ]; then
    export mutect2_normal_or_empty="$mutect2_normal_reads"
else
    export mutect2_normal_or_empty="null"
fi

# store arguments in a special array
mutect_args=(${mutect2_compress} ${mutect2_run_ob_filter} ${mutect2_make_bamout_or_default} \
             ${mutect2_run_funcotator_or_default} ${mutect2_filter_funcotations_or_default} \
             ${mutect2_output_basename} ${mutect2_unfiltered_name} ${mutect2_funcotated_name} \
             ${mutect2_output_vcf_name} ${mutect2_normal_or_empty})

mutect_names=(mutect2_compress mutect2_run_ob_filter mutect2_make_bamout_or_default \
              mutect2_run_funcotator_or_default mutect2_filter_funcotations_or_default \
              mutect2_output_basename mutect2_unfiltered_name mutect2_funcotated_name \
              mutect2_output_vcf_name mutect2_normal_or_empty)

# get number of elements
ELEMENTS=${#mutect_names[@]}
# echo each element in array - for loop
for (( x=0;x<$ELEMENTS;x++)); do
    echo "${mutect_names[${x}]}: ${mutect_args[${x}]}"
done

# For tasks, don't worry about runtime variables.
# This can be considered the "call M2" section - based off the mutect2.wdl.
#dx-jobutil-add-output splitintervals_interval_files "$splitintervals_interval_files" --class=array:file

#-----------------------------M2-----------------------------
echo "M2 task starting..."
# Inputs
export m2_intervals="${mutect2_intervals}"  # This may be optional.
export m2_ref_fasta="${mutect2_ref_fasta}"
export m2_ref_fai="${mutect2_ref_fai}"
export m2_ref_dict="${mutect2_ref_dict}"
export m2_tumor_bam="${mutect2_tumor_reads}"
#export m2_tumor_bai="${mutect2_tumor_reads_index}" # Don't need this since the path to the cram files was mounted onto the Docker container and those paths contain both the cram and crai file.
export m2_normal_bam="${mutect2_normal_reads}"
export m2_normal_bai="${mutect2_normal_reads_index}"
export m2_pon="${mutect2_pon}"
export m2_pon_idx="${mutect2_pon_idx}"
export m2_gnomad="${mutect2_gnomad}"
export m2_gnomad_idx="${mutect2_gnomad_idx}"
export m2_preemptible="${mutect2_preemptible}"
export m2_max_retries="${mutect2_max_retries}"
export m2_m2_extra_args="--downsampling-stride 20 --max-reads-per-alignment-start 6 --max-suspicious-reads-per-alignment-start 6 -alleles " # This has to be here due to issues feeding this in as a variable to the docker container.
export m2_getpileupsummaries_extra_args="${mutect2_getpileupsummaries_extra_args}"
export m2_variants_for_contamination="${mutect2_variants_for_contamination}"
export m2_variants_for_contamination_idx="${mutect2_variants_for_contamination_idx}"
export m2_run_ob_filter="${mutect2_run_ob_filter}"
export m2_compress="${mutect2_compress}"
export m2_make_bamout="${mutect2_make_bamout_or_default}"
export m2_gga_vcf="${mutect2_gga_vcf}"
export m2_gga_vcf_idx="${mutect2_gga_vcf_idx}"
export m2_gatk_override="${mutect2_gatk_override}"

if [ "$m2_compress" == "true" ]; then
    export m2_output_vcf="output.vcf.gz"
else
    export m2_output_vcf="output.vcf"
fi
if [ "$m2_compress" == "true" ]; then
    export m2_output_vcf_idx="${m2_output_vcf}.tbi"
else
    export m2_output_vcf_idx="${m2_output_vcf}.idx"
fi

export m2_output_stats="${m2_output_vcf}.stats"

echo "m2_intervals: ${m2_intervals}"
echo "m2_ref_fasta: ${m2_ref_fasta}"
echo "m2_ref_fai: ${m2_ref_fai}"
echo "m2_ref_dict: ${m2_ref_dict}"
echo "m2_tumor_bam: ${m2_tumor_bam}"
#echo "m2_tumor_bai: ${m2_tumor_bai}"
echo "m2_normal_bam: ${m2_normal_bam}"
echo "m2_normal_bai: ${m2_normal_bai}"
echo "m2_pon: ${m2_pon}"
echo "m2_pon_idx: ${m2_pon_idx}${m2_pon_idx}"
echo "m2_gnomad: ${m2_gnomad}"
echo "m2_gnomad_idx: ${m2_gnomad_idx}"
echo "m2_preemptible: ${m2_preemptible}"
echo "m2_max_retries: ${m2_max_retries}"
echo "m2_m2_extra_args: ${m2_m2_extra_args}"
echo "m2_getpileupsummaries_extra_args: ${m2_getpileupsummaries_extra_args}"
echo "m2_variants_for_contamination: ${m2_variants_for_contamination}"
echo "m2_variants_for_contamination_idx: ${m2_variants_for_contamination_idx}"
echo "m2_run_ob_filter: ${m2_run_ob_filter}"
echo "m2_compress: ${m2_compress}"
echo "m2_make_bamout: ${m2_make_bamout}"
echo "m2_gga_vcf: ${m2_gga_vcf}"
echo "m2_gga_vcf_idx: ${m2_gga_vcf_idx}"
echo "m2_gatk_override: ${m2_gatk_override}"
echo "m2_output_vcf: ${m2_output_vcf}"
echo "m2_output_vcf_idx: ${m2_output_vcf_idx}"
echo "m2_output_stats: ${m2_output_stats}"

# Basenames
export m2_normal_bam_basename="`basename ${m2_normal_bam}`"
export m2_variants_for_contamination_basename="`basename ${m2_variants_for_contamination}`"
echo "m2_normal_bam_basename: ${m2_normal_bam_basename}"
echo "m2_variants_for_contamination_basename: ${m2_variants_for_contamination_basename}"

# Extra files for m2_m2_extra_args
export m2_m2_extra_args_files="${m2_extra_args_files}"
export m2_m2_extra_args_files_basename="`basename ${m2_m2_extra_args_files}`"
echo "m2_m2_extra_args_files_basename: ${m2_m2_extra_args_files_basename}"

# Command section
# We need to create these files regardless, even if they stay empty
touch bamout.bam
touch f1r2.tar.gz
echo "" > normal_name.txt

/gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" GetSampleName -R ${m2_ref_fasta} -I ${m2_tumor_bam} -O tumor_name.txt -encode
tumor_command_line="-I ${m2_tumor_bam} -tumor `cat tumor_name.txt`"

if [[ "${m2_normal_bam_basename}" != "null.txt" ]]; then
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" GetSampleName -R ${m2_ref_fasta} -I ${m2_normal_bam} -O normal_name.txt -encode
    normal_command_line="-I ${m2_normal_bam} -normal `cat normal_name.txt`"
fi

if [[ "${m2_make_bamout}" == "true" && "${m2_run_ob_filter}" == "true" ]]; then
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam \
            --f1r2-tar-gz f1r2.tar.gz \
            ${m2_m2_extra_args} \
            ${m2_m2_extra_args_files}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam \
            --f1r2-tar-gz f1r2.tar.gz \
            ${m2_m2_extra_args}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" == "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam \
            --f1r2-tar-gz f1r2.tar.gz
    fi
fi

if [[ "${m2_make_bamout}" == "true" && "${m2_run_ob_filter}" == "false" ]]; then
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam \
            ${m2_m2_extra_args} \
            ${m2_m2_extra_args_files}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam \
            ${m2_m2_extra_args}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" == "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --bam-output bamout.bam
    fi
fi

if [[ "${m2_make_bamout}" == "false" && "${m2_run_ob_filter}" == "true" ]]; then
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --f1r2-tar-gz f1r2.tar.gz \
            ${m2_m2_extra_args} \
            ${m2_m2_extra_args_files}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --f1r2-tar-gz f1r2.tar.gz \
            ${m2_m2_extra_args}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            --f1r2-tar-gz f1r2.tar.gz
    fi
fi

if [[ "${m2_make_bamout}" == "false" && "${m2_run_ob_filter}" == "false" ]]; then
    if [[ "${m2_m2_extra_args_files_basename}" != "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            ${m2_m2_extra_args} \
            ${m2_m2_extra_args_files}
    fi

    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" != "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf} \
            ${m2_m2_extra_args}
    fi
    if [[ "${m2_m2_extra_args_files_basename}" == "null.txt" && "${m2_m2_extra_args}" == "null" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" Mutect2 \
            -R ${m2_ref_fasta} \
            $tumor_command_line \
            $normal_command_line \
            --germline-resource ${m2_gnomad} \
            -pon ${m2_pon} \
            -L ${m2_intervals} \
            -O ${m2_output_vcf}
    fi
fi

m2_exit_code=$?

### GetPileupSummaries

# If the variants for contamination and the intervals for this scatter don't intersect, GetPileupSummaries
# throws an error.  However, there is nothing wrong with an empty intersection for our purposes; it simply doesn't
# contribute to the merged pileup summaries that we create downstream.  We implement this by with array outputs.
# If the tool errors, no table is created and the glob yields an empty array.
set +e

if [[ "${m2_variants_for_contamination_basename}" != "null.txt" ]]; then
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" GetPileupSummaries \
     -R ${m2_ref_fasta} \
     -I ${m2_tumor_bam} \
     --interval-set-rule INTERSECTION \
     -L ${m2_intervals} \
     -V ${m2_variants_for_contamination} \
     -L ${m2_variants_for_contamination} \
     -O tumor-pileups.table

    if [[ "${m2_normal_bam_basename}" != "null.txt" ]]; then
        /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" GetPileupSummaries \
        -R ${m2_ref_fasta} \
        -I ${m2_normal_bam} \
        --interval-set-rule INTERSECTION \
        -L ${m2_intervals} \
        -V ${m2_variants_for_contamination} \
        -L ${m2_variants_for_contamination} \
        -O normal-pileups.table
    fi
fi

# the script only fails if Mutect2 itself fails
#exit $m2_exit_code

# Outputs
export m2_unfiltered_vcf="${m2_output_vcf}"
export m2_unfiltered_vcf_idx="${m2_output_vcf_idx}"
export m2_output_bamOut="bamout.bam"
export m2_tumor_sample=`cat tumor_name.txt`
export m2_normal_sample=`cat normal_name.txt`
export m2_stats="${m2_output_stats}"
export m2_f1r2_counts="f1r2.tar.gz"

declare -a m2_tumor_pileups
m2_tumor_pileups=(`ls *tumor-pileups.table`)

declare -a m2_normal_pileups
m2_normal_pileups=(`ls *normal-pileups.table`)

echo "m2_unfiltered_vcf: ${m2_unfiltered_vcf}"
echo "m2_unfiltered_vcf_idx: ${m2_unfiltered_vcf_idx}"
echo "m2_output_bamOut: ${m2_output_bamOut}"
echo "m2_tumor_sample: ${m2_tumor_sample}"
echo "m2_normal_sample: ${m2_normal_sample}"
echo "m2_stats: ${m2_stats}"
echo "m2_f1r2_counts: ${m2_f1r2_counts}"
echo "m2_tumor_pileups: ${m2_tumor_pileups}"
echo "m2_normal_pileups: ${m2_normal_pileups}"
echo "M2 task finished!"

#-----------------------------LearnReadOrientation-----------------------------
echo "LearnReadOrientation task starting..."
if [[ "${mutect2_run_ob_filter}" != "false" ]]; then
    # Inputs
    export learnreadorientation_f1r2_tar_gz="${m2_f1r2_counts}"
    printf -v joined ' -I %s ' "${learnreadorientation_f1r2_tar_gz[@]}"

    echo "learnreadorientation_f1r2_tar_gz: ${learnreadorientation_f1r2_tar_gz}"

    # Command
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" LearnReadOrientationModel \
        ${joined} \
        -O "artifact-priors.tar.gz"

    # Outputs
    export learnreadorientation_artifact_prior_table="artifact-priors.tar.gz"
    echo "learnreadorientation_artifact_prior_table: ${learnreadorientation_artifact_prior_table}"
else
    export learnreadorientation_artifact_prior_table="null"
fi
echo "LearnReadOrientation task finished!"

#-----------------------------CalculateContamination-----------------------------
echo "CalculateContamination task starting..."
# Inputs
export calculatecontamination_tumor_pileups="${m2_tumor_pileups}" #m2_tumor_pileups is normally an array, but we expect only 1 tumor_pileup file.

# Command
/gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" CalculateContamination \
    -I ${calculatecontamination_tumor_pileups} \
    -O contamination.table \
    --tumor-segmentation segments.table

# Outputs
export calculatecontamination_contamination_table="contamination.table"
export calculatecontamination_maf_segments="segments.table"
echo "calculatecontamination_contamination_table: ${calculatecontamination_contamination_table}"
echo "calculatecontamination_maf_segments: ${calculatecontamination_maf_segments}"
echo "CalculateContamination task finished!"

#-----------------------------Filter-----------------------------
echo "Filter task starting..."
# Inputs
export filter_ref_fasta="${mutect2_ref_fasta}"
export filter_ref_fai="${mutect2_ref_fai}"
export filter_ref_dict="${mutect2_ref_dict}"
export filter_intervals="${mutect2_intervals}"
export filter_unfiltered_vcf="${m2_unfiltered_vcf}"
export filter_unfiltered_vcf_idx="${m2_unfiltered_vcf_idx}"
export filter_output_name="${mutect2_filtered_name}"
export filter_compress="${mutect2_compress}"
export filter_mutect_stats="${m2_stats}"
export filter_contamination_table="${calculatecontamination_contamination_table}"
export filter_maf_segments="${calculatecontamination_maf_segments}"
export filter_artifact_priors_tar_gz="${learnreadorientation_artifact_prior_table}"
export filter_m2_extra_filtering_args="${mutect2_m2_extra_filtering_args}" # Optional
export filter_filtered_vcf="${filter_output_vcf}"

# Command
if [[ "${filter_artifact_priors_tar_gz}" != "null"  && "${filter_m2_extra_filtering_args}" != "null" ]]; then
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" FilterMutectCalls \
        -V ${filter_unfiltered_vcf} \
        -R ${filter_ref_fasta} \
        -O ${filter_filtered_vcf} \
        --contamination-table ${filter_contamination_table} \
        --tumor-segmentation ${filter_maf_segments} \
        --ob-priors ${filter_artifact_priors_tar_gz} \
        -stats ${filter_mutect_stats} \
        --filtering-stats filtering.stats \
        ${filter_m2_extra_filtering_args}
elif [[ "${filter_artifact_priors_tar_gz}" == "null"  && "${filter_m2_extra_filtering_args}" != "null" ]]; then
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" FilterMutectCalls \
        -V ${filter_unfiltered_vcf} \
        -R ${filter_ref_fasta} \
        -O ${filter_filtered_vcf} \
        --contamination-table ${filter_contamination_table} \
        --tumor-segmentation ${filter_maf_segments} \
        -stats ${filter_mutect_stats} \
        --filtering-stats filtering.stats \
        ${filter_m2_extra_filtering_args}
elif [[ "${filter_artifact_priors_tar_gz}" == "null"  && "${filter_m2_extra_filtering_args}" == "null" ]]; then
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" FilterMutectCalls \
        -V ${filter_unfiltered_vcf} \
        -R ${filter_ref_fasta} \
        -O ${filter_filtered_vcf} \
        --contamination-table ${filter_contamination_table} \
        --tumor-segmentation ${filter_maf_segments} \
        -stats ${filter_mutect_stats} \
        --filtering-stats filtering.stats
else
    /gatk/gatk --java-options "-Xmx${mutect2_command_mem}m" FilterMutectCalls \
        -V ${filter_unfiltered_vcf} \
        -R ${filter_ref_fasta} \
        -O ${filter_filtered_vcf} \
        --contamination-table ${filter_contamination_table} \
        --tumor-segmentation ${filter_maf_segments} \
        --ob-priors ${filter_artifact_priors_tar_gz} \
        -stats ${filter_mutect_stats} \
        --filtering-stats filtering.stats
fi

# Outputs
#export filter_filtered_vcf="${filter_output_vcf}"
#export filter_filtered_vcf_idx="${filter_output_vcf_idx}"
export filter_filtering_stats="filtering.stats"
echo "filter_filtered_vcf: ${filter_filtered_vcf}"
#echo "filter_filtered_vcf_idx: ${filter_filtered_vcf_idx}"
echo "filter_filtering_stats: ${filter_filtering_stats}"
echo "Filter task finished!"
