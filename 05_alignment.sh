#!/bin/bash

# Definir los directorios de archivos de entrada, de salida y el directorio del genoma y el directorio del índice.

trim_data="/home/mgonzalezpesquera/tfm/data/processed/02.Trimming"
align_data="/home/mgonzalezpesquera/tfm/data/processed/03.Alignment"
genome_dir="/home/mgonzalezpesquera/tfm/reference_genome"
genome_index="/home/mgonzalezpesquera/tfm/reference_genome/GRCh37_index"

# Definir el fasta descomprimido.

genome_fasta="$genome_dir/Homo_sapiens.GRCh37.dna.primary_assembly.fa"

# Verificar que el archivo fasta exista.

if [ ! -f "$genome_fasta" ]; then
  echo "⚠️ ERROR: No se encontró el archivo fasta del genoma en $genome_dir ⚠️"
  echo "Por favor descomprime el genoma antes de continuar."
  exit 1
fi

# Ejecutar hisat2-build para generar el índice.

echo "Generando índice HISAT2 para el genoma..."
hisat2-build "$genome_fasta" "$genome_index"

# Comprobación de correcto indexado.

if [ $? -eq 0 ]; then
  echo "🎉 Índice generado correctamente en: $genome_index 🎉"
else
  echo "⚠️ ERROR: Falló la generación del índice ⚠️"
  exit 1
fi

# Crear el directorio de salida si no existe.

mkdir -p "$align_data"

# Acceder al directorio de trim data.

cd "$trim_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $trim_data ⚠️"
  exit 1
}

# Verificar que existan archivos *_100bp.fastq.gz.

if ! ls *_100bp.fastq.gz 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No se encontraron archivos *_100bp.fastq.gz en $trim_data ⚠️"
  echo "Ejecuta primero los scripts anteriores."
  exit 1
fi

echo "Iniciando alineamiento..."

# Recorrer todos los archivos *_R1_100bp.fastq.gz. 

for r1 in *_R1_100bp.fastq.gz; do

  # Generar nombre del archivo R2 correspondiente y nombre base.

  r2="${r1/_R1_100bp.fastq.gz/_R2_100bp.fastq.gz}"
  base_name=$(basename "$r1" "_R1_100bp.fastq.gz")

  # Comprobar si existe el archivo R2.

  if [[ -f "$r2" ]]; then
    echo "Alineando $base_name..."

    # Ejecutar Hisat2 para alineamiento.

    hisat2 -k 1 -x "$genome_index" -1 "$r1" -2 "$r2" -S "$align_data/${base_name}.sam" \
      --summary-file "$align_data/${base_name}_alignment_summary.txt"

	# Comprobación de correcto alineamiento.

    if [ $? -eq 0 ]; then
      echo "Alineamiento completado para $base_name"
    else
      echo "⚠️ ERROR en alineamiento para $base_name ⚠️"
    fi
  else
    echo "⚠️ No se encontró archivo pareado para $r1. Saltando... ⚠️"
  fi
done
echo "🎉 Alineamiento finalizado 🎉"

