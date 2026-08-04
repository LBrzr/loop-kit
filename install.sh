#!/usr/bin/env bash
#
# Pose les deux pièces que le plugin ne peut pas installer lui-même :
#
#   contrat/CLAUDE.md          → $CLAUDE_CONFIG_DIR/CLAUDE.md   (mémoire utilisateur)
#   contrat/MACHINE.exemple.md → $CLAUDE_CONFIG_DIR/MACHINE.md  (pièges de CETTE machine)
#
# Un plugin distribue des agents, des skills et des commandes. Il n'injecte pas de mémoire
# utilisateur, et il ne peut rien savoir des ports occupés sur ta machine.
#
# Ce script ne remplace jamais un fichier existant sans le sauvegarder.

set -euo pipefail

ICI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

echo "Dossier de configuration : $CONFIG"
[ -d "$CONFIG" ] || { echo "  ✗ introuvable. Lance Claude Code une fois, puis réessaie."; exit 1; }

poser() {
  local source="$1" cible="$2" quoi="$3"

  if [ ! -e "$cible" ]; then
    cp "$source" "$cible"
    echo "  ✓ $quoi posé"
    return
  fi

  if cmp -s "$source" "$cible"; then
    echo "  = $quoi déjà à jour"
    return
  fi

  # Un CLAUDE.md contient probablement tes propres règles : on ne les écrase pas.
  local copie="$cible.avant-loop-kit"
  cp "$cible" "$copie"
  echo "  ! $quoi existe déjà et diffère."
  echo "      sauvegarde : $copie"
  echo "      à fusionner à la main : diff \"$copie\" \"$source\""
}

poser "$ICI/contrat/CLAUDE.md"          "$CONFIG/CLAUDE.md"  "Contrat de travail"
poser "$ICI/contrat/MACHINE.exemple.md" "$CONFIG/MACHINE.md" "Pièges machine"

echo
echo "MACHINE.md décrit la machine sur laquelle il a été écrit — ports occupés, outils"
echo "rouges d'origine. Relis-le et adapte-le : c'est un modèle, pas une vérité."
echo
echo "Mode entraînement (recommandé sur un projet neuf) :"
echo "  touch \"$CONFIG/.goal-loop-training\""
