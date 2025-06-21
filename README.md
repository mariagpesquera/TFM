# Preprocesamiento de datos RNA-seq

Este repositorio contiene los scripts y notebooks necesarios para ejecutar el preprocesamiento de datos de RNA-seq del trabajo fin de máster. Se utilizan los datos del proyecto [PRJNA601326](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA601326). También se incluye el análisis posterior en R y Python.

---

## 📁 Estructura esperada del proyecto

```
/home/usuario/tfm/
├── data/
│   ├── raw/
│   └── processed/
│       ├── 01.Quality_control/
│       ├── 02.Trimming/
│       └── 03.Alignment/
├── results/
│   └── cytoscape/
│       ├── network_cases.cys
│       ├── network_controls.cys
│       ├── network_cases.graphml
│       ├── network_controls.graphml
│       ├── enrichment_cases.csv
│       └── enrichment_controls.csv
├── annotation/
├── reference_genome/
├── code/
│   ├── 01_download_data.sh
│   ├── 02_quality_control.sh
│   ├── 03_trimming.sh
│   ├── 04_quality_control_post.sh
│   ├── 05_alignment.sh
│   ├── 06_sam_bam_processing.sh
│   ├── 07_qualimap_evaluation.sh
│   ├── 08_featurecounts.sh
│   ├── analysis_script.R
│   ├── analysis_notebook.ipynb
│   ├── filter_enrichment.R
│   └── environment.yml
```

---

## ⚙️ Requisitos

Este proyecto requiere las siguientes herramientas instaladas en el entorno:

- `sra-tools`
- `fastqc`
- `multiqc`
- `hisat2`
- `samtools`
- `picard`
- `qualimap`
- `subread` (featureCounts)
- `R`, `Rscript`, y paquetes `edgeR`, `ggplot2`, etc.
- `Python`, `Jupyter Notebook`

Puedes instalar todo automáticamente usando el archivo `environment.yml`:

```bash
conda env create -f code/environment.yml
conda activate environment
```

---

## 🧪 Scripts bash de preprocesamiento

Todos los scripts se encuentran en `code/` y están numerados según el orden de ejecución:

### `01_download_data.sh`
Descarga los archivos `.fastq.gz` a partir de un archivo `SRR_Acc_List.txt` (se puede obtener de: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA601326%20&o=acc_s%3Aa)

### `02_quality_control.sh`
Ejecuta `fastqc` sobre los archivos raw y resume los resultados con `multiqc`.

### `03_trimming.sh`
Ejecuta `TrimGalore!` y `Cutadapt` para recortar lecturas a 100 bp, eliminar adaptadores y Ns.

### `04_quality_control_post.sh`
Ejecuta `fastqc` y `multiqc` sobre los archivos `.fq.gz` ya trimmeados, ubicados en `02.Trimming`.

### `05_alignment.sh`
Indexa el genoma y alinea las lecturas con `hisat2`. Los archivos `.sam` generados se guardan en `03.Alignment`.

### `06_sam_bam_processing.sh`
Convierte archivos SAM a BAM, los ordena, marca duplicados con `picard`, indexa y genera estadísticas con `samtools`.

### `07_qualimap_evaluation.sh`
Ejecuta `qualimap rnaseq` con los `.bam` deduplicados y la anotación `.gtf`.

### `08_featurecounts.sh`
Obtiene la matriz de recuentos final a partir de los BAM deduplicados usando `featureCounts`.

---

## 📊 Análisis posterior

El análisis posterior se realiza con:

- `analysis_script.R`: identifica genes diferencialmente expresados (DEGs) a partir de la matriz generada por featureCounts, usando edgeR.

- `analysis_notebook.ipynb`: calcula el valor gamma para cada muestra a partir de los datos procesados.

- `filter_enrichment.R`: filtra y resume los resultados de enriquecimiento funcional exportados desde Cytoscape, seleccionando términos significativos.

Los archivos están preparados para ser ejecutados dentro del mismo entorno conda.

Las visualizaciones de redes de genes se realizaron utilizando Cytoscape.

Se incluyen los siguientes archivos:

- `network_cases.cys`: red construida a partir de las muestras de casos.
- `network_controls.cys`: red construida a partir de las muestras de controles.
- `network_cases.graphml`: red construida a partir de las muestras de casos.
- `network_controls.graphml`: red construida a partir de las muestras de controles.

Estos archivos se encuentran en `results/cytoscape/` y pueden abrirse directamente con Cytoscape para explorar los nodos, interacciones y anotaciones. Se proporciona archivos `.graphml` para mejorar la interoperabilidad.

También se incluyen archivos de resultados de enriquecimiento funcional exportados desde Cytoscape:

- `enrichment_cases.csv`
- `enrichment_controls.csv`

Estos se encuentran en `results/cytoscape/` y pueden ser procesados con el script `filter_enrichment.R`.

---

## 🔁 Ejecución completa (en orden)

```bash
bash code/01_download_data.sh
bash code/02_quality_control.sh
bash code/03_trimming.sh
bash code/04_quality_control_post.sh
bash code/05_alignment.sh
bash code/06_sam_bam_processing.sh
bash code/07_qualimap_evaluation.sh
bash code/08_featurecounts.sh
```
A continuación, se ejecuta el script de R para el análisis de expresión diferencial. Después de generar las redes, se ejecuta el notebook de Python para calcular el valor gamma. Finalmente, se exportan los resultados de enriquecimiento desde Cytoscape y se ejecuta el script de R para filtrar los resultados.

---

## 👤 Autor

María González Pesquera  
Trabajo de Fin de Máster  
Bioinformática 

---

## 📎 Licencia

Este repositorio se proporciona con fines académicos. Puedes adaptarlo citando adecuadamente al autor/a.
