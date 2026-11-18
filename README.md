# Healthcare Spillover Effects

A research workspace for studying how healthcare interventions and outcomes vary across the United States, including whether effects appear to extend across geographic boundaries.

## Research direction

The project notes identify several candidate methods for spatial exploration and future model development:

- global and local spatial autocorrelation, including Moran's I;
- spatial regression;
- instrumental-variable and two-stage least-squares designs; and
- exploratory spatiotemporal graph-attention models.

None of these is fully implemented in the current code yet. They answer different questions and rely on different assumptions. Spatial association alone is not evidence of a causal spillover effect; causal claims require a defensible design, validated instruments, sensitivity analysis, and careful treatment of interference.

## Repository map

- `data-folder/` — project data and data dictionaries
- `literatures/` — background material and working literature notes
- `seed-funding-grant/` — proposal source and supporting assets
- `Integrated Health Analytics Engine.py` — an early pipeline sketch
- `references.bib` — bibliography used by project documents
- root Office/PDF files — proposals, dictionaries, and planning materials

## Reproducibility status

This repository is an active research archive, not yet an installable package. The Python pipeline is a prototype with placeholder input filenames, and there is no locked software environment. Before running an analysis:

1. review the relevant data dictionary and access terms;
2. confirm that local input paths match the script or document;
3. create a project-specific environment; and
4. record the data snapshot and model assumptions used for the result.

Large tabular files are tracked with Git LFS. Run `git lfs pull` after cloning when those files are needed.

## Data use

Only use data you have permission to use. Confirm de-identification, redistribution rights, and institutional requirements before adding or sharing healthcare data.
