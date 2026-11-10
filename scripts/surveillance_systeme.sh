#!/bin/bash
# =============================================================
# Fonctionnalité A — Surveillance système
# Affiche des informations sur l'utilisation :
#   - du processeur (modèle, coeurs, charge, % d'utilisation)
#   - de la mémoire (RAM et swap)
#   - des disques (espace utilisé / disponible par partition)
# Utilisation : ./surveillance_systeme.sh
# =============================================================

# --- En-tête : titre et date/heure courante ---
echo "=============================================="
echo "        SURVEILLANCE SYSTÈME"
echo "        $(date '+%d/%m/%Y %H:%M:%S')"   # date au format jj/mm/aaaa hh:mm:ss
echo "=============================================="

# =============================================================
# SECTION 1 : PROCESSEUR
# =============================================================
echo
echo "---------- PROCESSEUR ----------"

# Modèle du CPU : on lit la première ligne "model name" de /proc/cpuinfo,
# on garde ce qui suit les ":" et on retire l'espace initial
modele=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')

# Nombre de coeurs (threads) logiques disponibles
coeurs=$(nproc)

echo "Modèle           : $modele"
echo "Nombre de coeurs : $coeurs"

# Charge moyenne du système sur 1, 5 et 15 minutes (3 premiers champs de /proc/loadavg)
echo "Charge moyenne (1/5/15 min) : $(cut -d' ' -f1-3 /proc/loadavg)"

# Calcul du % d'utilisation CPU :
# /proc/stat contient des compteurs cumulés (en "ticks") depuis le démarrage.
# On fait deux lectures à 1 seconde d'intervalle et on compare les différences.
# Colonnes : user nice system idle iowait irq softirq steal
read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat   # 1re mesure
sleep 1
read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat   # 2e mesure

# Temps total écoulé (somme de tous les états) pour chaque mesure
total1=$((u1 + n1 + s1 + i1 + w1 + q1 + sq1 + st1))
total2=$((u2 + n2 + s2 + i2 + w2 + q2 + sq2 + st2))

dtotal=$((total2 - total1))               # temps total écoulé entre les 2 mesures
didle=$(( (i2 + w2) - (i1 + w1) ))        # temps d'inactivité (idle + iowait)

# Utilisation = (temps total - temps inactif) / temps total, en pourcentage
# (on évite la division par zéro au cas où)
if [ "$dtotal" -gt 0 ]; then
    usage=$(( 100 * (dtotal - didle) / dtotal ))
else
    usage=0
fi
echo "Utilisation CPU  : ${usage}%"

echo
echo "=============================================="
