# nf-mod-fastqc

This is GBI's FastQC Nextflow module.

Nextflow module for fastqc. Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-fastqc:latest`

## Processes

- `FASTQC` — TODO: describe inputs/outputs

## Use as submodule
```bash
git submodule add https://github.com/eit-gbi/nf-mod-fastqc.git modules/fastqc
```

Then in your pipeline:
```
include { FASTQC } from './modules/fastqc/main.nf'
```
