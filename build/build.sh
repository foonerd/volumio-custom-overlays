#!/bin/bash

set -e

OVERLAY_DIR="overlays"
OUTPUT_DIR="dtbo"
DTC_BIN=$(command -v dtc || true)

echo "[info] Volumio Custom Overlay Builder"
echo "[info] Checking environment..."

# -------- Dependency check --------
if [[ -z "$DTC_BIN" ]]; then
  echo "[error] Device Tree Compiler (dtc) not found. Please install it:"
  echo "        sudo apt install device-tree-compiler"
  exit 1
fi

# -------- Ensure output directory --------
mkdir -p "$OUTPUT_DIR"

# -------- Build all .dts files in overlay dir --------
echo "[info] Building overlays from: $OVERLAY_DIR"
for dts_file in "$OVERLAY_DIR"/*.dts; do
  [[ -e "$dts_file" ]] || { echo "[warn] No .dts files found."; exit 1; }

  filename=$(basename "$dts_file" .dts)
  output="$OUTPUT_DIR/${filename}.dtbo"

  echo "[build] Compiling $filename.dts → $filename.dtbo"
  dtc -I dts -O dtb -o "$output" "$dts_file"
done

echo "[done] All overlays built and stored in: $OUTPUT_DIR/"
