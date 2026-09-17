# nf-mod-fastqc

Nextflow module for FastQC (sequencing read quality control). Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-fastqc:v2.0.2`

## Processes

Each subtool lives in its own folder (nf-core style), with a `main.nf`, a
`meta.yml` and an nf-test case under `tests/`.

| Process | Path | Inputs | Emits |
| --- | --- | --- | --- |
| `FASTQC_FASTQC` | `fastqc/main.nf` | `tuple val(meta), path(r1), path(r2)` | `html`, `zip`, `versions_fastqc` |

## Publishing

These processes do **not** publish their own outputs. Publishing is the
consuming pipeline's job, via a workflow `output {}` block. This keeps the
module reusable across pipelines that want different result layouts.

## Tool arguments

Flags are passed through `task.ext.args` (and `args2`/`args3` where a process
runs more than one command) rather than read from pipeline `params`, so the
module never depends on a particular pipeline's parameter names:

```groovy
process {
    withName: FASTQC_FASTQC {
        ext.args = '--some-flag'
    }
}
```

## Use as submodule

Pin to a release tag rather than a branch, so pipeline runs stay reproducible:

```bash
git submodule add https://github.com/EIT-GBI/nf-mod-fastqc.git modules/fastqc
git -C modules/fastqc checkout v2.0.2
```

Then include the module's container config from your `nextflow.config`. Nextflow
does not read a submodule's config on its own, so without this line the
processes have no image:

```groovy
includeConfig 'modules/fastqc/conf/module.config'
```

`conf/module.config` pins the image to the version built from this same commit,
and carries no `manifest {}` block, so it will not overwrite your pipeline's
own manifest. Override it in your pipeline with a `withName` selector if needed.

And include the processes:

```groovy
include { FASTQC_FASTQC } from './modules/fastqc/fastqc/main.nf'
```

## Requirements

Nextflow 26.04.4 or newer.

## Tests

`nf-test test`. There is a stub test covering wiring and output names, and a
test that runs FastQC for real against `ghcr.io/eit-gbi/nf-mod-fastqc:latest`
and snapshots the report. The real test needs Docker.

Neither output can be snapshotted directly. The zip stores an mtime per entry,
so its checksum differs between two identical runs, and the HTML embeds the run
date. What is *inside* the zip is stable, so the test opens it and snapshots
`summary.txt` and the Basic Statistics block of `fastqc_data.txt` instead. The
leading `##FastQC <version>` line is dropped, since it moves whenever the image
is rebuilt.

## Releasing

Merging a PR to `main` with exactly one `bump:patch`, `bump:minor` or
`bump:major` label bumps `manifest.version` in `nextflow.config`, tags the
release and publishes the container image.
