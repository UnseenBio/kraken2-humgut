#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */

process EXTRACT_GENOMES {
  label 'minimal'

  input:
  path archive
  path table

  output:
  path '*.fna.gz', emit: genomes

  """
  tail --lines=+2 "${table}" | \
    cut --fields=5 | \
    sed --expression='s/\$/.fna.gz/' | \
    tar -xf "${archive}" --no-anchored --strip-components=1 --files-from -
  """
}

process ADD_TAXID {
  label 'minimal'

  input:
  tuple path(table), path(genome)

  output:
  path taxid_genome, emit: genome

  script:
  decompressed = genome.baseName
  taxid_genome = "tax_${decompressed}"
  """
  gzip --decompress --keep --force "${genome}"
  add_tax_id.py "${table}" "${decompressed}" "${taxid_genome}"
  """
}


process ADD_LIBRARY {
  input:
  path(database)
  path 'tax_*.fna'

  output:
  path "${database}/library/added", emit: library

  script:
  """
  cat tax_*.fna > humgut.fna
  kraken2-build --add-to-library humgut.fna \
    --threads ${task.cpus} \
    --db "${database}"
  """
}
