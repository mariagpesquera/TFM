# --------------------------------------------------

# Date: 06-05-2025

# --------------------------------------------------

# 1. Cargo las librerías necesarias.

library(edgeR)
library(limma)
library(ggplot2)
library(pheatmap)
library(tibble)

# 2. Establezco el work directory.

setwd(dir = "/home/mgonzalezpesquera/tfm")

# 3. Importo metadata.

sampleinfo <- read.delim(file = "Metadata_clean")

  # Elimino columnas no relevantes.

sampleinfo <- sampleinfo[-(3:18)]
sampleinfo <- sampleinfo[-(4:12)]
sampleinfo <- sampleinfo[-6]

  # Creo el factor group. 

group <- paste(sampleinfo$tissue, sampleinfo$isolate, sep = ".")
group <- factor(group)

# 4. Cargo la matriz de counts.

seqdata <- read.table("results/counts_matrix.txt", header = TRUE, sep = "\t", fill = TRUE, quote = "", row.names = "Geneid")

  # Elimino las columnas que no son muestras.

seqdata <- seqdata[-(1:5)]

  # Renombro las columnas.

colnames(seqdata) <- sampleinfo$Sample_Name

# 5. Calculo el porcentaje de genes con conteos > 0

percent_nonzero <- colMeans(seqdata > 0) * 100
print(percent_nonzero)


# --------------------------------------------------

# Date: 08-05-2025

# --------------------------------------------------

# 1. Creo el DGEList.

y <- DGEList(seqdata)
y$samples$group <- group
y$genes <- data.frame(GeneID = rownames(seqdata))

  # filtro.

keep <- filterByExpr(y)
summary(keep)
y <- y[keep, keep.lib.sizes=FALSE]

  # Boxplot antes de normalizar.

logCPM_pre <- cpm(y, log = TRUE)
boxplot(logCPM_pre, main = "Boxplot de logCPM antes de normalización", col = "lightblue")

# 2. Normalización.

y <- calcNormFactors(y)

  # Boxplot después de normalizar.

logCPM_post <- cpm(y, log = TRUE)
boxplot(logCPM_post, main = "Boxplot de logCPM después de normalización", col = "lightgreen")

  # MDS plot.

pch <- c(0,1,2,15,16,17)
colors <- rep(c("lightcoral", "mediumaquamarine"), 2)
plotMDS(y, col = colors[group], pch = pch[group], main = "MDS Plot", cex = 1.5)
legend("topleft", legend = levels(group),pch=pch, col = colors, ncol = 2, cex = 0.6)
dev.off()


# --------------------------------------------------

# Date: 10-05-2025

# --------------------------------------------------

# 1. Cálculo de dispersiones.

  # Creo el design.

design <- model.matrix(~ 0 + group)
colnames(design) <- levels(group)

  # Calculo las dispersiones generales y las plotteo.

y <- estimateDisp(y, design = design, robust = TRUE)
plotBCV(y)

  # Calculo los coeficientes y vuelvo a plottear.

fit <- glmQLFit(y, design = design, robust = TRUE)
plotQLDisp(fit)

# 2. Análisis de expresión diferencial.

  # Creo el contrast y hago el análisis.

LvsC <- makeContrasts(bone_marrow.Leukemia_child-peripheral_blood.peripheral_blood, levels = design)
res <- glmQLFTest(fit, contrast = LvsC)
res_corrected <- topTags(res, n=Inf)

  # Calculo el número de DEGs aplicando el corte.

is.de <- decideTests(res, adjust.method = "BH", FDR = 0.05, lfc = 3)
summary(is.de)

# 3. Representación.

  # Volcano plot.

    # Creo la tabla con los datos.

volcan <- res_corrected$table
volcan$DE <- "NO SIGNIFICATIVO"
volcan$DE[volcan$logFC >= 3 & volcan$FDR <= 0.05] <- "UP"
volcan$DE[volcan$logFC <= -3 & volcan$FDR <= 0.05] <- "DOWN"

    # Grafico.

ggplot(volcan, aes(x=logFC, y=-log10(FDR), col=DE)) +
  geom_point(size=0.3) +
  labs(title = "Volcanoplot")

  # MD Plot.

plotMD(res, status = is.de)
dev.off()


# --------------------------------------------------

# Date: 11-05-2025

# --------------------------------------------------

# 1. Creo una matriz de expresión normalizada.

logCPM_norm <- cpm(y, log = T)
rownames(logCPM_norm) <- y$genes$GeneID
colnames(logCPM_norm) <- paste(row.names(y$samples))

  # Filtro los DEGs.

DEG <- res_corrected$table[res_corrected$table$FDR <=0.05 & abs(res_corrected$table$logFC) >= 3,]

  # Selecciono los 20 genes con mayor |logFC|

top20_genes <- rownames(DEG)[order(abs(DEG$logFC), decreasing = TRUE)[1:20]]

  # Creo objeto para heatmap.

DEG_heatmap <- logCPM_norm[top20_genes, ]

  # Creo un Heatmap con los resultados.

pheatmap(DEG_heatmap, scale = "row", cluster_rows = T , cluster_cols = T,
         clustering_distance_rows = "euclidean", clustering_distance_cols = "euclidean",
         clustering_method = "ward.D2", cutree_cols = 2, fontsize_row = 10,
         display_numbers = F)

# 2. Exporto los valores de expresión normalizados de los DEGs por grupo.

  # Creamos los objetos a exportar.

DEG_norm <- logCPM_norm[row.names(DEG), ]
DEGs_control <- as.data.frame(DEG_norm[, -c(4, 5, 6)])
DEGs_control$Gene <- rownames(DEGs_control)
DEGs_control <- DEGs_control[, c("Gene", setdiff(names(DEGs_control), "Gene"))]
DEGs_tumor <- as.data.frame(DEG_norm[, -c(1, 2, 3)])
DEGs_tumor$Gene <- rownames(DEGs_tumor)
DEGs_tumor <- DEGs_tumor[, c("Gene", setdiff(names(DEGs_tumor), "Gene"))]

  # Exportar a un archivo CSV

write.table(DEGs_control, file = "DEGs_control.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
write.table(DEGs_tumor, file = "DEGs_tumor.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

# 3. Exporto los DEGs en total.

  # Creamos el objeto a exportar.

DEGs_to_export <- DEG[, -1]

  # Exportar a un archivo CSV.

write.table(DEGs_to_export, file = "DEGs_general.tsv", sep = "\t", row.names = TRUE)

# 4. Boxplot de lncRNA HMHBI.

  # Extraer el vector de expresión del gen

expresion <- as.numeric(DEG_norm["ENSG00000249881", ])

  # Crear data.frame largo para ggplot

df_plot <- data.frame(
  Muestra = colnames(DEG_norm),
  Expresion = expresion
)
grupo <- c("Control", "Control", "Control", "Caso", "Caso", "Caso")
df_plot$Grupo <- grupo

  # Crear boxplot

ggplot(df_plot, aes(x = Grupo, y = Expresion, fill = Grupo)) +
  geom_boxplot(outlier.shape = 21, outlier.fill = "white") +
  geom_jitter(width = 0.15, alpha = 0.6) +
  labs(
    title = "Expresión de lncRNA solapante de HMHBI en casos y controles",
    x = "Grupo",
    y = "logCPM"
  ) +
  scale_fill_manual(values = c("Caso" = "#e31a1c", "Control" = "#1f78b4")) +
  theme_minimal() +
  theme(legend.position = "none")

# 4. Boxplot de lncRNA HMHBI.

  # Extraer el vector de expresión del gen

expresion <- as.numeric(DEG_norm["ENSG00000259863", ])

  # Crear data.frame largo para ggplot

df_plot <- data.frame(
  Muestra = colnames(DEG_norm),
  Expresion = expresion
)
grupo <- c("Control", "Control", "Control", "Caso", "Caso", "Caso")
df_plot$Grupo <- grupo

  # Crear boxplot

ggplot(df_plot, aes(x = Grupo, y = Expresion, fill = Grupo)) +
  geom_boxplot(outlier.shape = 21, outlier.fill = "white") +
  geom_jitter(width = 0.15, alpha = 0.6) +
  labs(
    title = "Expresión de lncRNA SH3SR3-AS1 en casos y controles",
    x = "Grupo",
    y = "logCPM"
  ) +
  scale_fill_manual(values = c("Caso" = "#e31a1c", "Control" = "#1f78b4")) +
  theme_minimal() +
  theme(legend.position = "none")
