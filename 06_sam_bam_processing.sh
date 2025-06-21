#!/bin/bash

# Definir el directorio donde están los archivos SAM.

align_data="/home/mgonzalezpesquera/tfm/data/processed/03.Alignment"

# Acceder al directorio de align data.

cd "$align_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $align_data ⚠️"
  exit 1
}

# Verificar que existan archivos .sam.

if ! ls *.sam 1> /dev/null 2>&1; then
  echo "⚠️ ERROR: No se encontraron archivos .sam en $align_data ⚠️"
  echo "Ejecuta primero los scripts anteriores."
  exit 1
fi

echo "Iniciando procesamiento de archivos SAM..."

# Recorrer todos los archivos *.sam

for sam_file in *.sam; do

  # Obtener nombre base.

  base_name=$(basename "$sam_file" ".sam")

  echo "Procesando $base_name..."

  # Convertir SAM a BAM.

  samtools view -Sbh "$sam_file" > "${base_name}.bam"

  # Comprobar la correcta conversión.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló la conversión SAM->BAM para $base_name ⚠️"
    exit 1
  fi

  # Eliminar archivo SAM original.

  rm "$sam_file"

  # Ordenar archivo BAM.

  samtools sort "${base_name}.bam" -o "${base_name}.sorted.bam"

  # Comprobar la correcta ordenación.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló la ordenación para $base_name ⚠️"
    exit 1
  fi

  # Marcar duplicados con Picard.

  picard MarkDuplicates \
    I="${base_name}.sorted.bam" \
    O="${base_name}.dedup.bam" \
    M="${base_name}.metrics.txt"
    
  # Comprobar el correcto marcaje de duplicados.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló el marcado de duplicados para $base_name ⚠️"
    exit 1
  fi

  # Generar flagstat.

  samtools flagstat "${base_name}.dedup.bam" > "${base_name}.flagstat.txt"

  # Comprobar la correcta generación de flagstat.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló samtools flagstat para $base_name ⚠️"
    exit 1
  fi

  # Indexar BAM final.

  samtools index "${base_name}.dedup.bam"

  # Comprobar el correcto indexado.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló la indexación para $base_name ⚠️"
    exit 1
  fi

  # Generar stats del BAM.

  samtools stats "${base_name}.dedup.bam" > "${base_name}.dedup.bam.stats"

  # Comprobar la correcta generación de stats.

  if [ $? -ne 0 ]; then
    echo "⚠️ ERROR: Falló samtools stats para $base_name ⚠️"
    exit 1
  fi
  echo "🎉 Procesamiento completado para $base_name 🎉"
done
echo "🎉 Procesamiento SAM->BAM, marcado de duplicados, indexado y estadísticas finalizado 🎉"

