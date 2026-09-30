#!/usr/bin/env bash
#
# Génère et affiche le schéma RTL d'un module Verilog en PNG via Yosys et netlistsvg.
# Usage : ./schematic.sh <projet> [module_top]

set -euo pipefail

projet="${1:-}"
top_module="${2:-}"

if [[ -z "$projet" || ! -d "$projet" ]]; then
    echo "Usage : ./schematic.sh <projet> [module_top]"
    echo "Exemple : ./schematic.sh button"
    echo
    echo "Projets disponibles :"
    printf '  - %s\n' */ 2>/dev/null || true
    exit 1
fi

# Vérification des dépendances
for cmd in yosys netlistsvg; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Erreur : '$cmd' n'est pas installé."
        echo "Installe les dépendances avec :"
        echo "  brew install yosys node librsvg"
        echo "  npm install -g netlistsvg"
        exit 1
    fi
done

cd "$projet"
nom="$(basename "$PWD")"

# 1. Récupération des fichiers Verilog (en excluant les testbenches *_tb.v)
sources=()
while IFS= read -r f; do
    sources+=("$f")
done < <(find . -maxdepth 1 -name '*.v' ! -name '*_tb.v' | sort)

if [[ ${#sources[@]} -eq 0 ]]; then
    echo "Erreur : aucun fichier source .v (hors *_tb.v) trouvé dans '$nom'."
    exit 1
fi

echo "==> Analyse des sources : ${sources[*]}"

# 2. Options Yosys
yosys_cmds="read_verilog ${sources[*]}; proc; opt;"
if [[ -n "$top_module" ]]; then
    yosys_cmds="read_verilog ${sources[*]}; hierarchy -top $top_module; proc; opt;"
fi
yosys_cmds="$yosys_cmds write_json netlist.json"

# 3. Synthèse JSON avec Yosys
echo "==> Extraction de la netlist avec Yosys..."
yosys -p "$yosys_cmds"

# 4. Génération du SVG avec netlistsvg
echo "==> Génération du SVG avec netlistsvg..."
netlistsvg netlist.json -o rtl_schema.svg >/dev/null 2>&1
rm -f netlist.json

# 5. Conversion du SVG en PNG
echo "==> Conversion en PNG..."
if command -v rsvg-convert >/dev/null 2>&1; then
    # Convertit en PNG haute résolution (300 DPI)
    rsvg-convert -d 300 -p 300 rtl_schema.svg -o rtl_schema.png
elif command -v magick >/dev/null 2>&1; then
    magick -density 300 rtl_schema.svg rtl_schema.png
elif command -v sips >/dev/null 2>&1; then
    # Outil natif macOS (fallback)
    sips -s format png rtl_schema.svg --out rtl_schema.png >/dev/null 2>&1
else
    echo "Attention : aucun convertisseur SVG->PNG trouvé (rsvg-convert recommandé)."
    echo "Affichage du SVG à la place..."
    open rtl_schema.svg
    exit 0
fi

# Nettoyage du fichier SVG intermédiaire
rm -f rtl_schema.svg

# 6. Affichage du PNG sur macOS
echo "==> Ouverture de rtl_schema.png"
open rtl_schema.png
