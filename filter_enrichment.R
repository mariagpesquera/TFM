
# 1. Establezco el work directory.

setwd(dir = "/home/mgonzalezpesquera/tfm/enriquecimiento")

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

# 4. Obtengo el top 3 según p.value.

top3_tcl1 <- tcl1_ordenado[1:3,]
top3_tcl2 <- tcl2_ordenado[1:3,]
top3_tcl3 <- tcl3_ordenado[1:3,]

print(top3_tcl3)
top3_ccl1 <- ccl1_ordenado[1:3,]
top3_ccl3 <- ccl3_ordenado[1:3,]
top3_ccl4 <- ccl4_ordenado[1:3,]