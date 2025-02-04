# Genome pre-processing pipeline

This is a local pipeline to pre-process downloaded genomes before feeding them
to <https://github.com/nf-core/pairgenomealign>.

## What it does:

This pipeline takes genomes as inputs and soft-masks their repeats with the following software:

- tantan (our default choice from a long time because TRF used to be non-free).
- windowmasker
- repeatmasker

The input of repeatmasker can be any of:

- repeatmodeller (default)
- DFAM (optional)
- a custom repeat library (optional)

Repeatmasker and repeatmodeller are run from the same image as the standard _nf-core_ module. But it is possible to pass the URL to an alternative singularity image, for instance to use the latest [TE Tools container](https://github.com/Dfam-consortium/TETools?tab=readme-ov-file#dfam-te-tools-container)

The pipeline then merges the soft masks of the RepeatMasker runs, and then merges that with the tantan and WindowMasker runs.

Finally, the pipeline prepares a MultiQC report that shows the extent of masking for each tool.

## Disclaimer

This is not an official pipeline. This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) initative, and reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> The nf-core framework for community-curated bioinformatics pipelines.
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> Nat Biotechnol. 2020 Feb 13. doi: 10.1038/s41587-020-0439-x.

## Usage

First make a sample sheet with usual _nf-core_ pipelines.

`samplesheet.csv`:

```csv
sample,fasta
query_1,path-to-query-genome-file-one.fasta.gz
query_2,path-to-query-genome-file-two.fasta.gz
```

If the input is not compressed then pass the `--gzipped_input=false` parameter.
Note that mixing compressed and uncompressed input is not supported.

Then run the pipeline as usual:

```bash
nextflow run oist/LuscombeU_stlrepeatmask \
   -profile oist \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

Test the dev branch of the pipeline (adapt the `-w` option for your own case!

```bash
nextflow run oist/LuscombeU_stlrepeatmask \
   -profile oist,test \
   -w /flash/LuscombeU/`whoami`/cache/deletemeTest \
   --outdir results_test
```

Test the local checkout

```bash
nextflow run ./main.nf \
   -profile oist,test \
   -w /flash/LuscombeU/`whoami`/cache/deletemeTest \
   --outdir results_test
```

## Options

- Point `--repeatlib` to a FASTA file to have an extra RepeatMasker run using it as a library.
- Set `--taxon` to a taxon name to have an extra RepeatMasker run using the `-species` option set to that taxon.
- Point `--singularity_image` to a local file path like `/flash/LuscombeU/singularity.cacheDir/tetools_1.88.5.sif` or an URL to singularity image to replace the default one.
- Set the `--gzipped_input=false` parameter when the input is not compressed..

## Pipeline output

### `tantan`, `repeatmodeler`, `windowmasker`, `dfam` (optional), `extlib` (optional)

- Masked genome file (compressed).
- BED file representing the masked regions.
- Summary statistics of the softmasked genome.

## Resource usage

On a test run on haplotype-merged and diploid assemblies of _Oikopleura dioica_ (2n = 60 Mbp):

- CPU usage was ~50 % for most processes. RepeatModeller was allocated 24 cores and used ~10 on average.
- Memory usage was less than 1 GB for all processes except RepeatModeller (~6 GB, max 8 GB).
- All processes needed only 10 % of the allocated time, except for RepeatModeller, which took between 100 and 500 minutes.
- On a couple of primate genomes, RepeatModeller managed to keep its 24 cores 60% busy for ~30 hours using 40 GB memory.

## Future directions

- It may be interesting to add TRF and ULTRA, and compare and combine their results to the ones of tantan.

## Credits

This pipeline was originally written by [Mahdi](https://github.com/U13bs1125) and then
taken over by @charles-plessy.
