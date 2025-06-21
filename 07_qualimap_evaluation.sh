#!/bin/bash

# Definir el directorio donde están los archivos BAM finales y el directorio de salida de resultados.

align_data="/home/mgonzalezpesquera/tfm/data/processed/03.Alignment"
qualimap_results="/home/mgonzalezpesquera/tfm/results"

# Definir el archivo GTF.

gtf_file="/home/mgonzalezpesquera/tfm/annotation/Homo_sapiens.GRCh37.87.gtf"


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

echo "Iniciando evaluación de calidad con Qualimap..."

# Crear directorio de resultados si no existe.

mkdir -p "$qualimap_results"

# Recorrer los archivos BAM.

for bam_file in *.dedup.bam; do

  # Obtener nombre base.

  base_name=$(basename "$bam_file" ".dedup.bam")

  echo "Procesando $base_name..."

  # Ejecutar Qualimap.

  qualimap rnaseq --bam "$bam_file" \
    -gtf "$gtf_file" \
    --java-mem-size=4000M \
    -outdir "qc_${base_name}"

  # Comprobar la correcta ejecución de Qualimap.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Qualimap falló para $base_name ⚠️"
    exit 1
  fi
  echo "🎉 Evaluación completada para $base_name 🎉"
done
echo "🎉 Evaluación Qualimap finalizada para todas las muestras 🎉"

