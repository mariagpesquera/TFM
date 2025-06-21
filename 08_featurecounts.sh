#!/bin/bash

# Definir directorio con los archivos BAM finales y directorio de salida.

align_data="/home/mgonzalezpesquera/tfm/data/processed/03.Alignment"
results_dir="/home/mgonzalezpesquera/tfm/results"

# Definir el archivo GTF y el archivo de salida de la matriz.

gtf_file="/home/mgonzalezpesquera/tfm/annotation/Homo_sapiens.GRCh37.87.gtf"
counts_file="${results_dir}/counts_matrix.txt"

# Acceder al directorio con los BAM.

cd "$align_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $align_data ⚠️"
  exit 1
}

# Verificar que existan archivos .dedup.bam.

if ! ls *.dedup.bam 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No se encontraron archivos .dedup.bam en $align_data ⚠️"
  echo "Ejecuta primero los scripts anteriores."
  exit 1
fi

# Crear directorio de resultados si no existe.

mkdir -p "$results_dir"

echo "Generando matriz de conteos con featureCounts..."

# Ejecutar featureCounts con todos los archivos dedup.bam.

featureCounts -p -a "$gtf_file" -o "$counts_file" *.dedup.bam

# Comprobar la correcta ejecución de featureCounts.

if [ $? -ne 0 ]; then
  echo "⚠️ ERROR: featureCounts falló ⚠️"
  exit 1
fi
echo "🎉 Matriz de conteos generada correctamente en $counts_file 🎉"

