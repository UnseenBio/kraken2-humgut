#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { LOAD_TAXONOMY; LOAD_LIBRARY } from './modules/load'
include { EXTRACT_GENOMES; ADD_TAXID; ADD_LIBRARY } from './modules/humgut'
include { BUILD_KRAKEN; BUILD_BRACKEN } from './modules/build'

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.clusters = 'humgut_clst01.tbl.txt'
params.genome_archive = 'humgut_clst_genomes.tar'
params.database = 'HumGut01'
params.kmer_length = 35
params.minimizer_length = 31
params.minimizer_spaces = 7
params.outdir = 'results'

/* ############################################################################
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 * ############################################################################
 */

workflow {
  log.info """
************************************************************

Build Bracken Database
======================
Results Path: ${params.outdir}
Clusters: ${params.clusters}
Genome Archive: ${params.genome_archive}
Database Name: ${params.database}
K-mer Length: ${params.kmer_length}

************************************************************

  """

  archive = Channel.fromPath(params.genome_archive,
    checkIfExists: true
  )
  table = Channel.fromPath(params.clusters,
    checkIfExists: true
  )

  // Load the NCBI taxonomy.
  LOAD_TAXONOMY()

  // Extract the HumGut genomic sequences and add them to the kraken2 library.
  EXTRACT_GENOMES(archive, table)
  ADD_TAXID(table.combine(EXTRACT_GENOMES.out.genomes.flatten()))
  ADD_LIBRARY(LOAD_TAXONOMY.out.db, ADD_TAXID.out.genome.collect())

  // Load additional kraken2 standard libraries.
  LOAD_LIBRARY(LOAD_TAXONOMY.out.db.combine(Channel.of('viral', 'human', 'fungi')))

  // Build the kraken2 database from the taxonomy and all the libraries.
  libraries = ADD_LIBRARY.out.library.mix(LOAD_LIBRARY.out.library).collect()
  BUILD_KRAKEN(LOAD_TAXONOMY.out.db, libraries)

  // Create bracken mappings.
  read_lengths = Channel.of(75, 100, 150, 200, 250)
  BUILD_BRACKEN(BUILD_KRAKEN.out.db.combine(read_lengths))
}
