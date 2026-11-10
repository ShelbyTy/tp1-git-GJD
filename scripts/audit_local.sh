#!/usr/bin/env bash
# audit_local.sh — Fonctionnalité B : audit des comptes utilisateurs locaux
# Lecture seule, aucun droit administrateur requis. Compatible macOS et Linux.

 ----- Options -----
usage() {
  echo "Usage : $0 [-o fichier] [-h]"
  echo "  -o fichier : enregistre aussi le rapport dans un fichier"
  echo "  -h         : affiche cette aide"
}

FICHIER=""
while getopts "o:h" opt; do
  case "$opt" in
    o) FICHIER="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [ -n "$FICHIER" ]; then
  exec > >(tee "$FICHIER") 2>&1
fi

OS=$(uname -s)
echo "===== AUDIT DES COMPTES LOCAUX — $(hostname) — $(date '+%F %T') ====="
echo "Système : $OS"
echo
printf "%-20s %-8s %-30s %s\n" "UTILISATEUR" "UID" "HOME" "SHELL"

if [ "$OS" = "Darwin" ]; then
  # macOS : les comptes sont gérés par Directory Services
  dscl . -list /Users UniqueID | while read -r user uid; do
    if [ "$uid" -ge 500 ] || [ "$uid" -eq 0 ]; then
      home=$(dscl . -read "/Users/$user" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
      shell=$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}')
      printf "%-20s %-8s %-30s %s\n" "$user" "$uid" "$home" "$shell"
    fi
  done
else
  # Linux : lecture de /etc/passwd
  while IFS=: read -r user _ uid _ _ home shell; do
    if [ "$uid" -ge 1000 ] || [ "$uid" -eq 0 ]; then
      printf "%-20s %-8s %-30s %s\n" "$user" "$uid" "$home" "$shell"
    fi
  done < /etc/passwd
fi

echo
echo "----- Comptes administrateurs -----"
if [ "$OS" = "Darwin" ]; then
  dscl . -read /Groups/admin GroupMembership 2>/dev/null | cut -d: -f2
else
  for g in sudo wheel; do
    getent group "$g" >/dev/null && echo "$g :$(getent group "$g" | cut -d: -f4)"
  done
fi
echo
echo "----- 10 dernieres connexions -----"
last -n 10 2>/dev/null || echo "commande last indisponible"./scripts/audit_local.sh


echo
echo "----- Comptes desactives ou sans connexion possible -----"
if [ "$OS" = "Darwin" ]; then
  resultat=$(for user in $(dscl . -list /Users UniqueID | awk '$2>=500 {print $1}'); do
    auth=$(dscl . -read "/Users/$user" AuthenticationAuthority 2>/dev/null)
    shell=$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}')
    if echo "$auth" | grep -q "DisabledUser" || [ "$shell" = "/usr/bin/false" ]; then
      echo "$user"
    fi
  done)
else
  resultat=$(awk -F: '$3>=1000 && $7 ~ /(nologin|false)$/ {print $1 " (shell: " $7 ")"}' /etc/passwd)
fi
if [ -z "$resultat" ]; then
  echo "Aucun compte desactive"
else
  echo "$resultat"
fi


if [ -n "$FICHIER" ]; then
  echo
  echo "Rapport enregistre dans : $FICHIER"
fi