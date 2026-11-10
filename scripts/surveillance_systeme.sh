#!/bin/bash
# =============================================================
# Fonctionnalité A — Surveillance système
# Affiche des informations sur l'utilisation :
#   - du processeur (modèle, coeurs, charge, % d'utilisation)
#   - de la mémoire (RAM et swap)
#   - des disques (espace utilisé / disponible par partition)
# Utilisation : ./surveillance_systeme.sh
# Prérequis : Linux (lecture de /proc), coreutils, awk
# =============================================================

# -------------------------------------------------------------
# Fonctions utilitaires
# -------------------------------------------------------------

# Pourcentage entier : pourcentage <partie> <total>
# Renvoie 0 si le total est nul (évite la division par zéro)
pourcentage() {
    if [ "$2" -gt 0 ]; then
        echo $(( 100 * $1 / $2 ))
    else
        echo 0
    fi
}

# -------------------------------------------------------------
# En-tête : titre et date/heure courante
# -------------------------------------------------------------
echo "=============================================="
echo "        SURVEILLANCE SYSTÈME"
echo "        $(date '+%d/%m/%Y %H:%M:%S')"
echo "=============================================="

# =============================================================
# SECTION 1 : PROCESSEUR
# =============================================================
echo
echo "---------- PROCESSEUR ----------"

# Modèle : première ligne "model name" de /proc/cpuinfo, sans l'espace initial
modele=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')

# Nombre de coeurs (threads) logiques
coeurs=$(nproc)

echo "Modèle           : $modele"
echo "Nombre de coeurs : $coeurs"

# Charge moyenne sur 1, 5 et 15 minutes (3 premiers champs de /proc/loadavg)
echo "Charge moyenne (1/5/15 min) : $(cut -d' ' -f1-3 /proc/loadavg)"

# Utilisation CPU : /proc/stat contient des compteurs cumulés (en "ticks")
# depuis le démarrage. On lit deux fois à 1 seconde d'intervalle et on compare.
# Colonnes : user nice system idle iowait irq softirq steal
read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat
sleep 1
read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat

total1=$((u1 + n1 + s1 + i1 + w1 + q1 + sq1 + st1))
total2=$((u2 + n2 + s2 + i2 + w2 + q2 + sq2 + st2))

dtotal=$((total2 - total1))                 # temps total écoulé entre les 2 mesures
didle=$(( (i2 + w2) - (i1 + w1) ))          # temps inactif (idle + iowait)

# Utilisation = (temps total - temps inactif) / temps total, en %
usage=$(pourcentage $((dtotal - didle)) "$dtotal")
echo "Utilisation CPU  : ${usage}%"

# =============================================================
# SECTION 2 : MÉMOIRE (RAM et swap)
# =============================================================
echo
echo "---------- MÉMOIRE ----------"

# /proc/meminfo fournit les valeurs en kilo-octets (kB)
ram_totale=$(awk '/^MemTotal:/    {print $2}' /proc/meminfo)
ram_dispo=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
swap_totale=$(awk '/^SwapTotal:/  {print $2}' /proc/meminfo)
swap_libre=$(awk '/^SwapFree:/    {print $2}' /proc/meminfo)

# Mémoire utilisée = totale - disponible (MemAvailable inclut les caches récupérables)
ram_utilisee=$(( ram_totale - ram_dispo ))
swap_utilisee=$(( swap_totale - swap_libre ))

# Affichage en Mo (division entière des kB)
echo "RAM totale       : $(( ram_totale / 1024 )) Mo"
echo "RAM utilisée     : $(( ram_utilisee / 1024 )) Mo ($(pourcentage "$ram_utilisee" "$ram_totale")%)"
echo "RAM disponible   : $(( ram_dispo / 1024 )) Mo"

if [ "$swap_totale" -gt 0 ]; then
    echo "Swap total       : $(( swap_totale / 1024 )) Mo"
    echo "Swap utilisé     : $(( swap_utilisee / 1024 )) Mo ($(pourcentage "$swap_utilisee" "$swap_totale")%)"
else
    echo "Swap             : aucun swap configuré"
fi

# =============================================================
# SECTION 3 : DISQUES (espace par partition)
# =============================================================
echo
echo "---------- DISQUES ----------"

# df -P : format POSIX stable (une ligne par système de fichiers)
# -h : tailles lisibles (Go, Mo)
# -x : on exclut les systèmes de fichiers virtuels ou en mémoire
printf "%-22s %8s %8s %8s %6s  %s\n" "Partition" "Taille" "Utilisé" "Dispo" "Uti%" "Monté sur"
df -P -h -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs \
    | tail -n +2 \
    | awk '{ printf "%-22s %8s %8s %8s %6s  %s\n", $1, $2, $3, $4, $5, $6 }'

echo
echo "=============================================="
