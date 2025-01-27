#!/bin/bash nextflow
//nextflow.enable.dsl=2

process REGENIE_STEP_1 {
    container = 'quay.io/eqtlcatalogue/regenie:v3.2.1'
    
    // Process directives
    cpus 16
    memory { 4.GB * params.phenotype_list.split(',').size() }
    time '48h'
    
    publishDir "${params.outdir}/${params.prefix}/STEP1", mode:'copy',\
		pattern: "${phenotype_id}*"
    publishDir "${params.outdir}/${params.prefix}/logs", mode:'copy',\
		pattern:  ".command.out", saveAs: { filename -> "$phenotype_id-step1.out" }
    publishDir "${params.outdir}/${params.prefix}/STEP1", mode:'copy',\
		pattern:  ".command.sh", saveAs: { filename -> "$phenotype_id-step1.sh" }

    // Input data
    input:
    tuple val(pgen_id), path(pgen_file)
    val phenotype_id
    file phenotype_file
    file covariate_file

    // Output data
    output:
    val phenotype_id
    path "*_pred.list"
    file "*.loco.gz"
    path ".command.out"
    path ".command.sh"

    shell:
    '''
    regenie \
    --step 1 \
    --pgen !{pgen_id} \
    --phenoFile !{phenotype_file} \
    --phenoColList !{phenotype_id} \
    --covarFile !{covariate_file} \
    --covarColList !{params.covariate_list} \
    --use-relative-path \
    --bsize 1000 \
    --lowmem \
    --apply-rint \
    --lowmem-prefix !{phenotype_id}_tmp_rg \
    --gz \
    --threads !{task.cpus} \
    --out !{phenotype_id} \

    '''
}
