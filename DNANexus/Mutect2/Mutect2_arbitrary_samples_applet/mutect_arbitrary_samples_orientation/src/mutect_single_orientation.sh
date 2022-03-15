#!/bin/bash
# mutect 0.0.1
# Author: Brian Sharber, brian.sharber@vumc.org

main() {
    set -ex -o pipefail
    echo ${mutect2_intervals_path}
    dx-download-all-inputs --parallel
    #mv $normal_bai_path ~/in/normal_bam
    mv $mutect2_ref_fai_path ~/in/mutect2_ref_fasta
    mv $mutect2_ref_dict_path ~/in/mutect2_ref_fasta
    mv $mutect2_gnomad_idx_path ~/in/mutect2_gnomad
    mv $mutect2_pon_idx_path ~/in/mutect2_pon
    mv $mutect2_variants_for_contamination_idx_path ~/in/mutect2_variants_for_contamination
    mv $m2_extra_args_files_idx_path ~/in/m2_extra_args_files
    #cp $mutect2_tumor_reads_index_path ~/in/mutect2_tumor_reads # Array:file - these have a hierarchy of 0/file, 1/file, 2/file...

    # Copy all index (.crai) files to the same folder as their corresponding file (.cram).
    if (( ${#mutect2_tumor_reads[@]} <= 10 )); then
        for (( i=0 ; i<${#mutect2_tumor_reads[@]}; i++ ));
        do
            mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/${i}
            ls ~/in/mutect2_tumor_reads/${i}
        done
    elif (( ${#mutect2_tumor_reads[@]} > 10 && ${#mutect2_tumor_reads[@]} <= 100 )); then
        for (( i=0 ; i<${#mutect2_tumor_reads[@]}; i++ ));
        do
            if (( "$i" < 10 )); then
                mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/0${i}
                ls ~/in/mutect2_tumor_reads/0${i}
            else
                mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/${i}
                ls ~/in/mutect2_tumor_reads/${i}
            fi
        done
    elif (( ${#mutect2_tumor_reads[@]} > 100 && ${#mutect2_tumor_reads[@]} <= 1000 )); then
        for (( i=0 ; i<${#mutect2_tumor_reads[@]}; i++ ));
        do
            if (( "$i" < 10 )); then
                mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/00${i}
                ls ~/in/mutect2_tumor_reads/00${i}
            elif (( "$i" >= 10 && "$i" < 100 )); then
                mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/0${i}
                ls ~/in/mutect2_tumor_reads/0${i}
            else
                mv ${mutect2_tumor_reads_index_path[$i]} ~/in/mutect2_tumor_reads/${i}
                ls ~/in/mutect2_tumor_reads/${i}
            fi
        done
    else
        echo "More than 1000 samples per job is currently not supported."
    fi

    ls ~/in/mutect2_ref_fasta
    ls ~/in/mutect2_gnomad
    ls ~/in/mutect2_pon
    ls ~/in/mutect2_variants_for_contamination
    ls ~/in/m2_extra_args_files
    ls ~/in/mutect2_tumor_reads

    which dx

    echo "${mutect2_tumor_reads}"
    echo "${mutect2_tumor_reads[0]}"
    echo "${mutect2_tumor_reads[1]}"
    #echo "Entire array? ${mutect2_tumor_reads_path}" #nope - just the first element
    echo "${mutect2_tumor_reads_path[1]}" # index 1
    #echo "${mutect2_tumor_reads[1]_path}" #bad substitution
    echo "${mutect2_tumor_reads_path[@]}" #entire array

    docker load --input ${mutect2_gatk_docker_path}
    ## get <eid>_23153_0_0 from <eid>_23153_0_0.bqsr.bam
    eid_nameroot=$(echo $mutect2_tumor_reads_name | cut -d'.' -f1)
    output_name="$eid_nameroot.mutect.filtered.vcf.gz"

    # Make filtered_vcf an array and append values into it.
    declare -a filtered_vcf
    for file in "${mutect2_tumor_reads_prefix[@]}"
    do
        if [[ ${mutect2_compress_vcfs} != "false" ]]; then
            filtered_vcf+=("${file}-filtered.vcf.gz")
        else
            filtered_vcf+=("${file}-filtered.vcf")
        fi
    done

    echo "Entire array of filtered_vcf: ${filtered_vcf[@]}" #6969-NH-1.hg38-filtered.vcf 1099997_23153_0_0-filtered.vcf 1099976_23153_0_0-filtered.vcf

    #docker run --rm -v /mnt/UKBB_Exome_2021:/mnt/UKBB_Exome_2021 -v /usr/local/reference/:/usr/local/reference/
    # Arguments are being fed into the docker run command here - this spins up a docker container.
    # Mutect2.sh is the file that performs commands inside the docker container.
    for (( i=0; i<${#mutect2_tumor_reads[@]}; i++ ));
    do
    docker run --rm -v /home/dnanexus:/home/dnanexus -v /usr/local/bin/dx:/usr/local/bin/dx -v /usr/local/bin/dx-jobutil-add-output:/usr/local/bin/dx-jobutil-add-output \
        -v /usr/local/bin/:/usr/local/bin -v /usr/local/reference/:/usr/local/reference/ -w /home/dnanexus us.gcr.io/broad-gatk/gatk:4.1.6.0 \
        /bin/bash /usr/local/bin/Mutect2.sh \
        ${mutect2_ref_dict_path} ${mutect2_ref_fai_path} ${mutect2_ref_fasta_path} ${mutect2_scatter_count} ${mutect2_basic_bash_docker} \
        ${mutect2_boot_disk_size} ${mutect2_compress_vcfs} ${mutect2_cram_to_bam_multiplier} ${mutect2_emergency_extra_disk} ${mutect2_filter_alignment_artifacts_mem} \
        ${mutect2_filter_funcotations} ${mutect2_funco_annotation_defaults} ${mutect2_funco_annotation_overrides} ${mutect2_funco_compress} ${mutect2_funco_data_sources_tar_gz} \
        ${mutect2_funco_default_output_format} ${mutect2_funco_filter_funcotations} ${mutect2_funco_output_format} ${mutect2_funco_reference_version} ${mutect2_funco_transcript_selection_list} \
        ${mutect2_funco_transcript_selection_mode} ${mutect2_funco_use_gnomad_AF} ${mutect2_funcotator_excluded_fields} ${mutect2_funcotator_extra_args} ${mutect2_gatk_override} \
        ${mutect2_getpileupsummaries_extra_args} ${mutect2_gga_vcf_path} ${mutect2_gga_vcf_idx_path} ${mutect2_gnomad_path} ${mutect2_gnomad_idx_path} \
        ${mutect2_intervals_path} ${mutect2_large_input_to_output_multiplier} ${mutect2_learn_read_orientation_mem} ${mutect2_m2_extra_args} ${mutect2_m2_extra_filtering_args} \
        ${mutect2_make_bamout} ${mutect2_max_retries} ${mutect2_normal_reads_path} ${mutect2_normal_reads_index_path} ${mutect2_pon_path} \
        ${mutect2_pon_idx_path} ${mutect2_preemptible} ${mutect2_realignment_extra_args} ${mutect2_realignment_index_bundle} ${mutect2_run_funcotator} \
        ${mutect2_run_orientation_bias_mixture_model_filter} ${mutect2_sequence_source} ${mutect2_sequencing_center} ${mutect2_small_input_to_output_multiplier} ${mutect2_small_task_cpu} \
        ${mutect2_small_task_disk} ${mutect2_small_task_mem} ${mutect2_split_intervals_extra_args} ${mutect2_variants_for_contamination_path} ${mutect2_variants_for_contamination_idx_path} \
        ${m2_cpu} ${m2_mem} ${m2_use_ssd} ${calculatecontamination_intervals} ${mutect2_optionals} \
        ${m2_extra_args_files_path} ${m2_extra_args_files_idx_path} ${calculatecontamination_optionals} ${filter_optionals} ${filteralignmentartifacts_optionals} \
        ${mutect2_normal_reads_prefix} ${mutect2_normal_reads_name} ${mutect2_command_mem} ${splitintervals_interval_files_path} ${output_name} \
        "${mutect2_tumor_reads_path[i]}" "${mutect2_tumor_reads_prefix[i]}" "${mutect2_tumor_reads_name[i]}" "${filtered_vcf[i]}"

        filtered_vcf_output=$(dx upload "${filtered_vcf[i]}" --brief)
        dx-jobutil-add-output filtered_vcf_output "${filtered_vcf_output}" --class=file --array
    done
}
