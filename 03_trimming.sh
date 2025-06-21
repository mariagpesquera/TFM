#!/bin/bash

# Definir directorios de raw data y de datos trimmeados.

raw_data="/home/mgonzalezpesquera/tfm/data/raw"
trim_data="/home/mgonzalezpesquera/tfm/data/processed/02.Trimming"

# Crear el directorio de salida si no existe.

mkdir -p "$trim_data"

# Acceder al directorio de raw data.

cd "$raw_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $raw_data ⚠️"
  exit 1
}

# Verificar que existan archivos *_1.fastq.gz.

if ! ls *_1.fastq.gz 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No se encontraron archivos *_1.fastq.gz en $raw_data ⚠️"
  echo "Ejecuta primero los scripts anteriores"
  exit 1
fi

echo "Iniciando trimming y recorte a 100 pb..."

# Recorrer todos los archivos *_1.fastq.gz (R1)

for r1 in *_1.fastq.gz; do

  # Generar nombre del archivo R2 correspondiente.

  r2="${r1/_1.fastq.gz/_2.fastq.gz}"

  # Comprobar si existe el archivo R2.

  if [[ -f "$r2" ]]; then
    echo "Procesando $r1 y $r2..."

    # Ejecutar Trim Galore! para trimming y filtrado.

    trim_galore --length 100 --illumina --trim-n --paired --output_dir "$trim_data" "$r1" "$r2"

    # Obtener nombre base para recortes posteriores.

    base_name=$(basename "$r1" "_1.fastq.gz")

    # Archivos resultantes del trimming.

    trimmed_r1="$trim_data/${base_name}_1_val_1.fq.gz"
    trimmed_r2="$trim_data/${base_name}_2_val_2.fq.gz"

    # Archivos finales con exactamente 100 pb.

    fixed_r1="$trim_data/${base_name}_R1_100bp.fastq.gz"
    fixed_r2="$trim_data/${base_name}_R2_100bp.fastq.gz"

    # Recortar todas las lecturas a exactamente 100 pb con Cutadapt.

    cutadapt -l 100 -o "$fixed_r1" -p "$fixed_r2" "$trimmed_r1" "$trimmed_r2"

  else
    echo "⚠️ No se encontró el archivo pareado para $r1. Saltando... ⚠️"
  fi
done
echo "🎉 Trimming y recorte a 100 pb completado 🎉"

