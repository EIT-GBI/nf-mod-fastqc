process FASTQC {
    tag "${meta.id}"
    label 'process_low'

    // Making big changes

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"), emit: zip
    tuple val("${task.process}"), val('fastqc'), eval('fastqc --version | sed "/FastQC v/!d; s/.*v//"'), emit: versions_fastqc, topic: versions

    script:
    def args = task.ext.args ?: ''
    """
    fastqc \\
        ${args} \\
        --threads ${task.cpus} \\
        ${reads}
    """
}
