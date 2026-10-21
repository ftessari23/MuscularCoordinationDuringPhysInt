# A Shared Command with Individualized Preferences Explains Muscle Coordination During Physical Interaction

MATLAB code to reproduce the Main and Supporting Figures and the statistical analyses of the paper:

> **A Shared Command with Individualized Preferences Explains Muscle Coordination During Physical Interaction**
> Federico Tessari, et al.
> DOI: `<add DOI>`

The script is a single file (`main_EMG_coord_v2.m`). Running it loads the pre-processed data and generates all figures and statistics, one section at a time. Expected run time is about 20 seconds.

---

## Requirements

### Software
- **MATLAB R2020b or newer.** The script uses `tiledlayout` (R2019b), `exportgraphics` (R2020a) and `subtitle` (R2020b).
- **Statistics and Machine Learning Toolbox.** The script uses `anova2`, `tinv`, `tcdf` and `tiedrank`.
- **DIEM toolbox.** Download it from `[<DIEM repository URL>](https://github.com/ftessari23/diem)` and place the unzipped folder `DIEM-main` in the same directory as the script. It provides `getDIEM`, `getCosineSimilarity` and `DIEM_Stat`. The script adds it to the MATLAB path automatically.

### Data files
The following `.mat` files must be in the same folder as the script (`TBD`):

| File | Contents |
|---|---|
| `rep_subj_data.mat` | EMG of the representative subject: single repetitions and average (`t_rep_tr`, `EMG_rep_tr`, `t_rep_avg`, `EMG_rep_avg`) |
| `EMG_syn_res_norm_max.mat` | Synergy extraction results: cumulative VAF (`cVAF`), synergy temporal evolutions (`EMG_time_tot`) and activation coefficients (`EMG_weight_tot`) |
| `DIEM_stats_8h_4315w.mat` | Pre-computed DIEM statistics for H1 and W1 (`exp_center_h`, `vard_h`, `min_DIEM_h`, `exp_center_w`, `vard_w`, `min_DIEM_w`) |
| `results_EMG_phases.mat` | Average EMG during force-hold and position-hold phases (`results_EMG_avg.fh`, `results_EMG_avg.ph`) |
| `DIEM_stat_N8_bs.mat` | Pre-computed DIEM statistics for the 8-muscle force-hold vs. position-hold comparison (`exp_center_bs`, `vard_bs`, `min_DIEM_bs`) |

### Expected folder structure
```
.
├── <main_script_name>.m
├── DIEM-main/
├── rep_subj_data.mat
├── EMG_syn_res_norm_max.mat
├── DIEM_stats_8h_4315w.mat
├── results_EMG_phases.mat
├── DIEM_stat_N8_bs.mat
└── PaperFigures/        (optional, only needed to export figures)
```

---

## How to run

1. Place the script, the data files and the `DIEM-main` folder in the same directory.
2. Open MATLAB and set that directory as the current folder.
3. Run the script:
   ```matlab
   main_EMG_coord_v2.m
   ```
   You can also run it section by section with **Run Section**.

The script starts with `clear; clc; close all;`, so it clears the workspace and closes all open figures.

---

## What the code does

The script is divided into sections that run in order.

### 1. Representative subject EMG (Figure 1)
Plots the post-processed EMG of one representative subject (flexor carpi radialis, direction +Y, F = 25 N, d = 50 mm). It shows the single repetitions and their average. The dashed line marks t = 0.

### 2. Muscle synergy analysis (Figures 2 and 3)
- **Figure 2:** cumulative Variance-Accounted-For (cVAF) vs. number of synergies, with the 90% reference line. Next to it, the temporal evolution of the first synergy as mean ± SD across all directions, subjects and conditions.
- **Figure 3:** temporal evolution of the synergies for the 1-, 2- and 3-synergy solutions (mean ± SD).

Only subjects 7–20 are used, because subjects 1–6 have no trapezius recording.

### 3. Within- vs. between-subject similarity of H1 and W1 (Figures 4–11)
H1 is the first synergy's activation coefficients. W1 is its temporal evolution. Both are compared using **Cosine Similarity** and **DIEM**.

For each of the 4 force directions (+x, +y, -x, -y):
- **Between-subject** similarity: different subjects, same condition.
- **Within-subject** similarity: same subject, different conditions.
- Histograms of the similarity values, with the median as a dashed line. Figures 4–11 are one Cosine and one DIEM figure per direction.

The test statistic is **Δ = mean(within-subject similarity) − mean(between-subject similarity)**.
For Cosine, Δ > 0 means within-subject values are more similar. For DIEM, Δ < 0 means that.

Inference is done in three steps:
1. **Permutation test.** Subject labels are shuffled within each condition (10,000 permutations, `rng(1)` for reproducibility).
2. **Subject-level delete-one jackknife.** It gives a standard error, an approximate 95% CI and a sensitivity p-value, plus influence diagnostics.
3. **Holm correction** across the 16 tests (4 directions × 2 metrics × 2 components).

The rank-biserial correlation and the medians are reported as descriptive statistics only and are not used for inference.

**Console output:**
- A consistency check per direction. Block diagonals must reproduce the within-subject values, so the printed differences should be about 1e-15 or smaller.
- The final results table (`resultsTbl`), with Δ, CI, raw and Holm-adjusted p-values, effect size and influence diagnostics.
- The smallest attainable permutation p-value.

### 4. Sanity check
Compares a single off-diagonal entry of the cross-condition similarity block with an explicit calculation, for both Cosine and DIEM. The printed values should agree.

### 5. Force hold vs. position hold, per muscle (8 figures)
For each muscle, grouped bar plots of the mean ± SD EMG of every subject in force hold (FH, blue) and position hold (PH, red), for the 4 directions.

### 6. Two-way ANOVA
For each muscle and direction, a two-way ANOVA tests the effect of subject and of phase (FH vs. PH), and their interaction.
The p-values are stored in `p_res` (muscle × [subject, phase, interaction] × direction). This section produces no figure.

### 7. Between-subject DIEM for force hold and position hold (8 figures)
For each direction and each phase:
- Histogram of the DIEM across all subject pairs.
- Bar plots of the EMG profiles of the subject pairs with the **minimum**, **median** and **maximum** DIEM.

---

## Outputs

| Output | Description |
|---|---|
| Figures | 27 MATLAB figures: 1 + 1 + 1 + 8 (similarity) + 8 (muscles) + 8 (DIEM FH/PH) |
| `resultsTbl` | Statistics table of the similarity analysis (workspace variable) |
| `p_res` | ANOVA p-values (workspace variable) |
| `diem_stats` | Min / median / max DIEM and subject pairs for FH and PH (workspace variable) |

Figure and table exports are **commented out** by default. To enable them:
1. Create a `PaperFigures` folder in the working directory.
2. Uncomment the lines marked `Uncomment below to save figure` in the relevant sections.
3. To save the results table, uncomment the `writetable` and `save` lines after the Holm correction.

---

## Reproducibility notes

- The permutation test uses a fixed seed (`rng(1)`).
- DIEM statistics are stochastic by nature. The pre-computed files are loaded so that the results match the paper exactly. The `DIEM_Stat` call in section 7 is left commented. Re-computing the statistics will slightly change some numbers.
- The figures use LaTeX interpreters for labels and titles.

---

## Citation

If you use this code, please cite:

```
TBD
```

## License

MIT License

## Contact

Federico Tessari, PhD, Massachusetts Institute of Technology, ftessari@mit.edu
