process REPEATMODELER_MASKER {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    def singularity_image = params.singularity_image ?: 'https://depot.galaxyproject.org/singularity/repeatmodeler:2.0.5--pl5321hdfd78af_0'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        singularity_image :
        'biocontainers/repeatmodeler:2.0.5--pl5321hdfd78af_0' }"

    input:
    tuple val(meta), path(fasta), path(ref)
    val(taxon)

    output:
    tuple val(meta), path("*.masked") , emit: fasta
    tuple val(meta), path("*.cat")    , emit: cat
    tuple val(meta), path("*.out")    , emit: out
    tuple val(meta), path("*.tbl")    , emit: tbl
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args    = task.ext.args ?: ''
    def prefix  = task.ext.prefix ?: "${meta.id}"
    def libOrTaxon = taxon ? "-species ${taxon}" : "-lib $fasta"
    """
    RepeatMasker \\
        -xsmall -pa 3 \\
        -$libOrTaxon \\
        $ref \\
        $args \\

    mv ${ref}.masked ${prefix}.masked
    mv ${ref}.out    ${prefix}.out
    mv ${ref}.tbl    ${prefix}.tbl
    if [ -e ${ref}.cat ] ; then mv ${ref}.cat ${prefix}.cat; fi
    if [ -e ${ref}.cat.gz ] ; then mv ${ref}.cat.gz ${prefix}.cat; fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        repeatmodeler: \$(RepeatModeler --version | sed 's/RepeatModeler version //')
    END_VERSIONS
    """

    stub:
    def prefix  = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fas

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        repeatmodeler: \$(RepeatModeler --version | sed 's/RepeatModeler version //')
    END_VERSIONS
    """
}