# Gregory Way 2017
# PanCancer Classifier
# scripts/snaptron/investigate_silent_junctions.R
#
# Analyzes and plots junctions observed in c.375G>T mutant TP53 mutations
#
# Usage: Run by scripts/snaptron/dna_damage_repair_tp53exon.sh
#
# Output:
# Plots of exon-exon junctions for c.375G>T mutated samples and a random set of
# wildtype samples. Also a fishers exact test comparing enrichment of 200 bp
# exon 4 truncation in mutated samples versus wildtype

library(RColorBrewer)

set.seed(123)

snaptron_file <- 'junctions_with_mutations.csv'
junc_df <- readr::read_csv(snaptron_file)
junc_df <- junc_df[, -1]
junc_df <- junc_df[!duplicated(junc_df), ]

# Sort data for plotting later
junc_df <- junc_df[order(junc_df$diff_end, decreasing = FALSE), ]
junc_df <- junc_df[order(junc_df$weight, decreasing = TRUE), ]

# Location of the start of exon 5
junc_df <- junc_df[junc_df$start == "7675237", ]

# Subset to only silent mutations and be sure to exclude samples that have
# other types of mutations as well
silent_mutations <- junc_df[junc_df$HGVSc %in% 'c.375G>T', ] 
silent_mutations <- silent_mutations[silent_mutations$total_status %in% 0, ]

# Get random wild type samples for plotting as well
random_wt <- sample(unique(junc_df[junc_df$total_status == 0, ]$tcga_id), 19)
wt_junc <- junc_df[junc_df$tcga_id %in% random_wt, ]

# Setup colors for plotting
cols <- c("red", "darkmagenta", "cornflowerblue", "darkgoldenrod1",
          "aquamarine", "cornsilk2")
snaptron_ids <- unique(silent_mutations[order(silent_mutations$length,
                                     decreasing = TRUE), ]$snaptron_id)
color_frame <- data.frame(cbind(snaptron_ids, cols))
colnames(color_frame) <- c("snaptron", "color")

# Setup blank plot
pdf("exon-exon_junctions.pdf", height = 5, width = 5)
op <- par(mar = c(5,4,4,4) + 0.1, oma = rep(0, 4))
plot(range(silent_mutations$start - 100, silent_mutations$end + 200),
     range(-33, 1), type  = "n", xlab = "", ylab = "", axes = FALSE)
title("TP53 Exon-Exon Junctions", line = 0.5, font.main = 4, cex.main = 0.8)
mtext("Genomic Location (chr 17)", side = 1, cex = 0.6, line = 2)
axis(side = 1, at = seq(7675200, 7676200, by = 200),
     labels = TRUE, font = 3, cex.axis = 0.5, lwd = 0.5)
par(op)
idx = 0
for (samp in unique(silent_mutations$tcga_id)) {
  silent_junc_sub <- silent_mutations[silent_mutations$tcga_id == samp, ]
  silent_junc_sub <- silent_junc_sub[order(silent_junc_sub$length,
                                           decreasing = TRUE),]
  row_idx = 0
  for (row in 1:nrow(silent_junc_sub)) {
    junction = silent_junc_sub[row, ]
    snap_id = junction$snaptron_id
    weight = junction$weight
    use_col <- paste(color_frame[color_frame$snaptron == snap_id, ]$color)
    id <- junction$tcga_id
    x = junction$start
    x1 = junction$end
    
    rect(xleft = x,
         ybottom = 0.2 - idx - row_idx,
         xright = x1,
         ytop = -0.2 - idx - row_idx,
         col = use_col,
         lwd = 0.5)
    row_idx = row_idx + 0.22
  }
  text(x = 7675760, y = -idx + 0.65, id, cex = 0.4)
  text(x = 7676315, y = -idx, paste(format(round(weight, 2), nsmall = 2)),
       cex = 0.4)
  idx = idx + 1.85
}
text(x = 7676325, y = 1.9, "Probability", font = 3, cex = 0.5)
text(x = 7675237, y = 2, "Exon 5", font = 3, cex = 0.5)
text(x = 7675994, y = 2, "Exon 4", font = 3, cex = 0.5)
segments(x = 7676193, x0 = 7676193, y = -45, y0 = 1, col = "red",
         lty = "dashed", lwd = 0.7)
segments(x = 7675994, x0 = 7675994, y = -45, y0 = 1, col = "blue",
         lty = "dashed", lwd = 0.7)
segments(x = 7675237, x0 = 7675237, y = -45, y0 = 1, col = "black",
         lty = "dashed", lwd = 0.7)
dev.off()

# Plots of WT samples
pdf("exon-exon_junctions_wt_random.pdf", height = 5, width = 5)
op <- par(mar = c(5,4,4,4) + 0.1, oma = rep(0, 4))
plot(range(silent_mutations$start - 100, silent_mutations$end + 200), range(-33, 1),
     type  = "n", xlab = "", ylab = "", axes = FALSE)
title("TP53 Exon-Exon Junctions", line = 0.5, font.main = 4, cex.main = 0.8)
mtext("Genomic Location (chr 17)", side = 1, cex = 0.6, line = 2)
axis(side = 1, at = seq(7675200, 7676200, by = 200),
     labels = TRUE, font = 3, cex.axis = 0.5, lwd = 0.5)
par(op)
idx = 0
for (samp in unique(wt_junc$tcga_id)) {
  silent_junc_sub <- wt_junc[wt_junc$tcga_id == samp, ]
  silent_junc_sub <- silent_junc_sub[order(silent_junc_sub$length,
                                           decreasing = TRUE),]
  row_idx = 0
  for (row in 1:nrow(silent_junc_sub)) {
    junction = silent_junc_sub[row, ]
    snap_id = junction$snaptron_id
    weight = junction$weight
    use_col <- paste(color_frame[color_frame$snaptron == snap_id, ]$color)
    id <- junction$tcga_id
    x = junction$start
    x1 = junction$end
    
    rect(xleft = x,
         ybottom = 0.2 - idx - row_idx,
         xright = x1,
         ytop = -0.2 - idx - row_idx,
         col = use_col)
    row_idx = row_idx + 0.22
  }
  text(x = 7675525, y = -idx + 0.65, id, cex = 0.4)
  text(x = 7676315, y = -idx, paste(format(round(weight, 2), nsmall = 2)),
       cex = 0.4)
  idx = idx + 1.85
}
text(x = 7676325, y = 1.9, "Probability", font = 3, cex = 0.5)
text(x = 7675237, y = 2, "Exon 5", font = 3, cex = 0.5)
text(x = 7675994, y = 2, "Exon 4", font = 3, cex = 0.5)
segments(x = 7676193, x0 = 7676193, y = -45, y0 = 1, col = "red",
         lty = "dashed", lwd = 0.7)
segments(x = 7675994, x0 = 7675994, y = -45, y0 = 1, col = "blue",
         lty = "dashed", lwd = 0.7)
segments(x = 7675237, x0 = 7675237, y = -45, y0 = 1, col = "black",
         lty = "dashed", lwd = 0.7)
dev.off()

# Enrichment analysis of 200 bp TP53 splice junction (snaptron_id = 13945701)
trunc <- junc_df[junc_df$snaptron_id == 13945701, ]
wt_trunc <- trunc[trunc$total_status == 0, ]
wt_trunc <- length(unique(wt_trunc$tcga_id))

total_wt <- junc_df[junc_df$total_status == 0, ]
total_wt <- length(unique(total_wt$tcga_id))

silent_trunc <- trunc[trunc$HGVSc %in% 'c.375G>T', ]
silent_trunc <- silent_trunc[silent_trunc$total_status %in% 0, ]
silent_trunc <- length(unique(silent_trunc$tcga_id))

total_silent <- length(unique(silent_mutations$tcga_id))

f_test <- data.frame(c(silent_trunc, total_silent), c(wt_trunc, total_wt))
sink("fishers_exon4_truncation_enrichment_in_c375G-T_mutations.txt")
print(f_test)
fisher.test(f_test)
sink()