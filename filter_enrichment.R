
# 1. Establezco el work directory.

setwd(dir = "/home/mgonzalezpesquera/tfm/enriquecimiento")

library(ggplot2)
library(dplyr)

# 2. Cargo las tablas obtenidas de Cytoscape.

tumor_cluster1 <- read.table("TUMOR_0.70_FINAL_CLUSTER1.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")
tumor_cluster2 <- read.table("TUMOR_0.70_FINAL_CLUSTER2.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")
tumor_cluster3 <- read.table("TUMOR_0.70_FINAL_CLUSTER3.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")

control_cluster1 <- read.table("CONTROL_0.60_FINAL_CLUSTER1.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")
control_cluster3 <- read.table("CONTROL_0.60_FINAL_CLUSTER3.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")
control_cluster4 <- read.table("CONTROL_0.60_FINAL_CLUSTER4.csv", header = TRUE, sep = ",", fill = TRUE, quote = "")

# 3. Ordeno por pvalue.

tcl1_ordenado <- tumor_cluster1[order(tumor_cluster1$p.value), ]
tcl2_ordenado <- tumor_cluster2[order(tumor_cluster2$p.value), ]
tcl3_ordenado <- tumor_cluster3[order(tumor_cluster3$p.value), ]

ccl1_ordenado <- control_cluster1[order(control_cluster1$p.value), ]
ccl3_ordenado <- control_cluster3[order(control_cluster3$p.value), ]
ccl4_ordenado <- control_cluster4[order(control_cluster4$p.value), ]

# Añade una columna con -log10(p-valor)

tcl1_ordenado$logP <- -log10(tcl1_ordenado$p.value)
tcl2_ordenado$logP <- -log10(tcl2_ordenado$p.value)
tcl3_ordenado$logP <- -log10(tcl3_ordenado$p.value)

ccl1_ordenado$logP <- -log10(ccl1_ordenado$p.value)
ccl3_ordenado$logP <- -log10(ccl3_ordenado$p.value)
ccl4_ordenado$logP <- -log10(ccl4_ordenado$p.value)

# Añado columna de clúster a cada tabla
tcl1_top10 <- tcl1_ordenado[1:10, ]
tcl1_top10$Cluster <- "Clúster 1"
tcl2_top10 <- tcl2_ordenado[1:10, ]
tcl2_top10$Cluster <- "Clúster 2"
tcl3_top10 <- tcl3_ordenado[1:10, ]
tcl3_top10$Cluster <- "Clúster 3"

ccl1_top10 <- ccl1_ordenado[1:10, ]
ccl1_top10$Cluster <- "Clúster 1"
ccl3_top10 <- ccl3_ordenado[1:10, ]
ccl3_top10$Cluster <- "Clúster 3"
ccl4_top10 <- ccl4_ordenado[1:10, ]
ccl4_top10$Cluster <- "Clúster 4"

# Convierto term.size en un integral.
tcl1_top10$term.size <- as.integer(tcl1_top10$term.size)
tcl2_top10$term.size <- as.integer(tcl2_top10$term.size)
tcl3_top10$term.size <- as.integer(tcl3_top10$term.size)

ccl1_top10$term.size <- as.integer(ccl1_top10$term.size)
ccl3_top10$term.size <- as.integer(ccl3_top10$term.size)
ccl4_top10$term.size <- as.integer(ccl4_top10$term.size)


# Une todos en un único data.frame
tumor_combined <- bind_rows(tcl1_top10, tcl2_top10, tcl3_top10)
tumor_combined$NumGenes <- sapply(tumor_combined$intersecting.genes, function(x) {
  length(unique(unlist(strsplit(x, "\\|"))))
})

control_combined <- bind_rows(ccl1_top10, ccl3_top10, ccl4_top10)
control_combined$NumGenes <- sapply(control_combined$intersecting.genes, function(x) {
  length(unique(unlist(strsplit(x, "\\|"))))
})

# Represento.

ggplot(tumor_combined, aes(x = Cluster, y = term.name, size= NumGenes, color = logP)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(
    title = "Leucemia: Rutas enriquecidas por clúster",
    x = "Clúster",
    y = "Ruta enriquecida",
    size = "Nº genes",
    color = "-log10(p-valor)"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5)
  )

ggplot(control_combined, aes(x = Cluster, y = term.name, size = NumGenes, color = logP)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(
    title = "Control: Rutas enriquecidas por clúster",
    x = "Clúster",
    y = "Ruta enriquecida",
    size = "Nº genes",
    color = "-log10(p-valor)"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 8),
    plot.title = element_text(hjust = 0.5)
  )
