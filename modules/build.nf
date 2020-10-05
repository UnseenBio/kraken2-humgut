#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.kmer_length = 35
params.minimizer_length = 31
params.minimizer_spaces = 7

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */

process BUILD_KRAKEN {
  input:
  path(database)
  path('*')

  output:
  path database, emit: db

  script:
  """
  kraken2-build --build \
    --db "${database}" \
    --threads ${task.cpus} \
    --kmer-len ${params.kmer_length} \
    --minimizer-len ${params.minimizer_length} \
    --minimizer-spaces ${params.minimizer_spaces}
  """
}


process BUILD_BRACKEN {
  input:
  tuple path(database), val(read_length)

  output:
  path database, emit: db

  script:
  """
  bracken-build \
    -d "${database}" \
    -t ${task.cpus} \
    -k ${params.kmer_length} \
    -l ${read_length}
  """
}