#!/bin/bash

# Definir los directorios de raw data y los resultados del control de calidad.

raw_data="/home/mgonzalezpesquera/tfm/data/raw"
quality_control="/home/mgonzalezpesquera/tfm/data/processed/01.Quality_control"

# Crear el directorio de control de calidad si no existe.

mkdir -p "$quality_control"

# Verificar que haya archivos fastq.gz en el directorio raw.

cd "$raw_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $raw_data ⚠️"
  exit 1
}

if ! ls *.fastq.gz 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No hay archivos .fastq.gz en $raw_data ⚠️"
  echo "Ejecuta primero el script anterior"
  exit 1
fi

# Ejecutar FastQC.

echo "Ejecutando FastQC..."
fastqc *.fastq.gz -o "$quality_control"

# Ir al directorio de resultados de control de calidad.

cd "$quality_control" || {
  echo "⚠️ ERROR: No se pudo acceder a $quality_control ⚠️"
  exit 1
}

# Ejecutar MultiQC.

echo "Generando reporte con MultiQC..."
multiqc .
echo "🎉 Análisis de calidad completado. Revisa el archivo multiqc_report.html en $quality_control 🎉"

