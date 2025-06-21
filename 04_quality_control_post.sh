#!/bin/bash

# Definir los directorios de raw data y los resultados del control de calidad.

trim_data="/home/mgonzalezpesquera/tfm/data/processed/02.Trimming"
quality_control_post="/home/mgonzalezpesquera/tfm/data/processed/02.Trimming/quality_control_trimming"

# Crear el directorio de control de calidad si no existe.

mkdir -p "$quality_control_post"

# Verificar que haya archivos fastq.gz en el directorio raw.

cd "$trim_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $trim_data ⚠️"
  exit 1
}

if ! ls *.fastq.gz 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No hay archivos .fastq.gz en $trim_data ⚠️"
  echo "Ejecuta primero los scripts anteriores"
  exit 1
fi

# Ejecutar FastQC.

echo "Ejecutando FastQC..."
fastqc *.fastq.gz -o "$quality_control_post"

# Ir al directorio de resultados de control de calidad.

cd "$quality_control_post" || {
  echo "⚠️ ERROR: No se pudo acceder a $quality_control_post ⚠️"
  exit 1
}

# Ejecutar MultiQC.

echo "Generando reporte con MultiQC..."
multiqc .
echo "🎉 Análisis de calidad completado. Revisa el archivo multiqc_report.html en $quality_control_post 🎉"

