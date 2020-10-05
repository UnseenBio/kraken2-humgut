# Build HumGut Reference

Use the [HumGut genome clusters](http://arken.nmbu.no/~larssn/humgut/index.htm)
to create a [kraken2](https://github.com/DerrickWood/kraken2) database and
[bracken](https://github.com/jenniferlu717/Bracken) classifier mappings for
different expected read lengths.

## Usage

1. Set up nextflow as [described
   here](https://www.nextflow.io/index.html#GetStarted).
2. If you didn't run this pipeline in a while, possibly update nextflow itself.
   ```
   nextflow self-update
   ```
3. Then run the pipeline.
   ```
   nextflow run main.nf
   ```

## Copyright

- Copyright © 2020, Unseen Bio ApS.
- Free software distributed under the [GNU Affero General Public License version
  3 or later (AGPL-3.0-or-later)](https://opensource.org/licenses/AGPL-3.0).
