process FASTQC {
    tag "${meta.id}"
    label 'process_low'

    // Making big changes

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"), emit: zip
    tuple val("${task.process}"), val('fastqc'), eval('fastqc --version | sed "/FastQC v/!d; s/.*v//"'), emit: versions_fastqc, topic: versions

    script:
    def args = task.ext.args ?: ''
    """
    # Making breaking change
    fastqc \\
        ${args} \\
        --threads ${task.cpus} \\
        ${r1} ${r2}
    """

    stub:
    """
    touch ${meta.id}_R1_fastqc.zip ${meta.id}_R1_fastqc.html
    touch ${meta.id}_R2_fastqc.zip ${meta.id}_R2_fastqc.html
    """
}
