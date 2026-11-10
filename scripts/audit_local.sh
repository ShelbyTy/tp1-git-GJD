#!/usr/bin/env bash
# audit_local.sh — Fonctionnalité B : audit des comptes utilisateurs locaux
# Lecture seule, aucun droit administrateur requis. Compatible macOS et Linux.

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
last -n 10 2>/dev/null || echo "commande last indisponible"