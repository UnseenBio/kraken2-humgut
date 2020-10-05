#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.database = 'HumGut01'
params.outdir = 'results'

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */

process LOAD_TAXONOMY {
  label 'minimal'
  publishDir params.outdir, mode: 'symlink'

  output:
  path params.database, emit: db

  """
  kraken2-build --download-taxonomy --db "${params.database}"
  """
}

process LOAD_LIBRARY {
  label 'minimal'

  input:
  tuple path(database), val(library)

  output:
  path "${database}/library/${library}", emit: library

  script:
  """
  kraken2-build --download-library ${library} --db "${database}"
  """
}
