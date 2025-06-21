#!/bin/bash

# Definir el directorio de raw data.

raw_data="/home/mgonzalezpesquera/tfm/data/raw/" 

# Crear el directorio si no existe.

mkdir -p "$raw_data"

# Ir al directorio donde se descargará la raw data.

cd "$raw_data" || {
  echo "⚠️ ERROR: No se pudo acceder al directorio $raw_data ⚠️"
  exit 1
}

# Verificar que exista el archivo SRR_Acc_List.txt

if [ ! -f "SRR_Acc_List.txt" ]; then
  echo "⚠️ ERROR: No se encuentra el archivo SRR_Acc_List.txt en $raw_data ⚠️"
  echo "Descárgalo desde el proyecto PRJNA601326 y colócalo aquí."
  exit 1
fi

# Descargar los archivos .fastq.gz desde la lista de accesiones del proyecto

echo "Descargando datos desde accesiones SRA..."
xargs -n1 fastq-dump --gzip --split-files < SRR_Acc_List.txt
echo "🎉 Descarga completada 🎉"
