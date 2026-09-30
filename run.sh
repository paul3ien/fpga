#!/usr/bin/env bash
#
# Compile, simule et ouvre Surfer pour un projet de test FPGA.
#
# Usage : ./run.sh <projet>     (ex. ./run.sh counter)

set -euo pipefail

projet="${1:-}"

if [[ -z "$projet" || ! -d "$projet" ]]; then
    echo "Usage : ./run.sh <projet>   (ex. ./run.sh counter)"
    echo
    echo "Projets disponibles :"
    printf '  - %s\n' */ 2>/dev/null || true
    exit 1
fi

cd "$projet"
nom="$(basename "$PWD")"

# 1. Tous les fichiers Verilog du dossier
sources=()
while IFS= read -r f; do
    sources+=("$f")
done < <(find . -maxdepth 1 -name '*.v' | sort)

if [[ ${#sources[@]} -eq 0 ]]; then
    echo "Erreur : aucun fichier .v dans '$nom'."
    exit 1
fi

# 2. Compilation
#    -g2012 : active le SystemVerilog (nécessaire pour les ports tableaux du parser)
echo "==> Compilation ($nom) : ${sources[*]}"
iverilog -g2012 -o "$nom.vvp" "${sources[@]}"

# 3. Simulation (génère le(s) fichier(s) .vcd)
echo "==> Simulation"
vvp "$nom.vvp"

# 4. Visualisation
ondes=(./*.vcd)
if [[ -e "${ondes[0]}" ]]; then
    if command -v surfer >/dev/null 2>&1; then
        echo "==> Surfer : ${ondes[*]}"
        surfer "${ondes[@]}" >/dev/null 2>&1 &
    else
        echo "Surfer introuvable. Ouvre manuellement : ${ondes[*]}"
    fi
else
    echo "Aucun .vcd généré (vérifie \$dumpfile dans le testbench)."
fi
