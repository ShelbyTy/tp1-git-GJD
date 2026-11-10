# tp1-git-GJD

# TP1 - Administration & Gestion de projet Git / GitHub

Boîte à outils de scripts d'administration système (surveillance, audit, vérification des services), réalisée en équipe pour mettre en pratique Git, Git Flow et GitHub (Issues, Projects, Pull Requests, revues).

## 👤 Identification de l'équipe

| Nom | Prénom | Pseudonyme GitHub | Rôle | Branche de travail | Fonctionnalité |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Lecaillier | Jean | @ShelbyTy | Étudiant 1 | `features/scriptA` | A — Surveillance système |
| Cornu | Dorian | @dorian-cornu4 | Étudiant 2 | `features/scriptB` | B — Audit local |
| Grignet Le Perron | Gaspard | @krisiksDev | Étudiant 3 | `features/scriptC` | C — Vérification des services |

---

## Fonctionnalité A — Surveillance système (Étudiant 1)

**Responsable :** Jean Lecaillier (@ShelbyTy)
**Fichier :** `scripts/surveillance_systeme.sh`

### Ce que fait le script
- Affiche la date et l'heure du relevé
- Processeur : modèle, nombre de coeurs, charge moyenne (1/5/15 min) et pourcentage d'utilisation (mesure sur 1 seconde via `/proc/stat`)
- Mémoire : RAM totale, utilisée (avec %) et disponible, ainsi que le swap (ou "aucun swap configuré")
- Disques : taille, espace utilisé, disponible et pourcentage par partition (systèmes de fichiers virtuels exclus)

### Prérequis
- Linux (lecture de `/proc`)
- Bash, coreutils, awk
- Aucun droit administrateur nécessaire : le script ne fait que lire, il ne modifie rien sur le système

### Exécution
```bash
chmod +x scripts/surveillance_systeme.sh
./scripts/surveillance_systeme.sh
```

---

## Fonctionnalité B — Audit local (Étudiant 2)

**Responsable :** Dorian Cornu (@dorian-cornu4)
**Fichier :** `scripts/audit_local.sh`

### Ce que fait le script
- Liste les comptes utilisateurs locaux (nom, UID, dossier personnel, shell)
- Affiche les comptes administrateurs (groupe `admin` sur macOS, `sudo`/`wheel` sur Linux)
- Affiche les 10 dernières connexions
- Détecte les comptes désactivés ou qui ne peuvent pas se connecter

### Prérequis
- macOS ou Linux
- Bash
- Aucun droit administrateur nécessaire : le script ne fait que lire, il ne modifie rien sur le système

### Exécution
```bash
chmod +x scripts/audit_local.sh
./scripts/audit_local.sh                 # affiche le rapport
./scripts/audit_local.sh -o rapport.txt  # affiche et enregistre le rapport
./scripts/audit_local.sh -h              # affiche l'aide
```

---

## Fonctionnalité C — Vérification des services (Étudiant 3)

**Responsable :** Gaspard Grignet Le Perron (@krisiksDev)
**Fichier :** `scripts/check-services.ps1`

### Ce que fait le script
Contrôle l'état de services Windows prédéfinis (`Spooler`, `W32Time`, `TermService`) et génère un compte rendu horodaté avec un statut clair (`[OK]` ou `[ALERTE]`) pour chaque service.

### Prérequis
- Windows 10 / 11 ou Windows Server
- Windows PowerShell 5.1 ou PowerShell 7+
- Aucun droit administrateur nécessaire (lecture seule via `Get-Service`)

### Exécution
```powershell
cd path\to\tp1-git-GJD
.\scripts\check-services.ps1
```

---

## Workflow (Git Flow)

- `main` : versions stables uniquement (tags `v1.0`, `v1.0.1`)
- `develop` : développement en cours
- `features/*` : une branche par fonctionnalité, intégrée dans `develop` par Pull Request
- `release/*` : préparation de la version 1.0
- `hotfix/*` : correction urgente de la version en production
- Toute intégration passe par une Pull Request relue et approuvée par 2 membres
- Chaque commit et chaque Pull Request référence son Issue (`#numéro`) pour la traçabilité
- Protection des branches `main` et `develop` : [À COMPLÉTER : règles activées dans Settings > Branches, ou limitation GitHub rencontrée et règle appliquée manuellement]

## Étapes de développement

1. Création des Issues, du Project (Kanban) et de la Roadmap
2. Création de la branche `develop`
3. Développement des fonctionnalités A, B et C sur leurs branches `features/*`, puis Pull Requests et revues
4. Conflit volontaire sur un fichier commun, puis résolution
5. Correction du bug d'affichage disque dans `develop`
6. Branche `release`, puis publication de la v1.0
7. Hotfix sur le script de vérification des services, puis publication de la v1.0.1

---

## Questions de synthèse

### 1. Pourquoi séparer le dev en cours et les versions stables ?
**Auteur :** Étudiant 1 (Jean Lecaillier)
**Réponse :**
Ça évite de casser ce qui marche. Les versions stables, c'est ce que les utilisateurs ont entre les mains, donc ça doit toujours fonctionner. Le dev en cours, c'est là où on teste et où on ajoute des trucs, et forcément ça peut être buggé par moments. Si tout était mélangé, le moindre bout de code pas fini pourrait partir en prod.

### 2. Pourquoi faire une revue de code avant d'intégrer ?
**Auteur :** Étudiant 1 (Jean Lecaillier)
**Réponse :**
Parce qu'à plusieurs on voit plus de choses que tout seul. Quelqu'un d'autre peut repérer un bug, un oubli ou un truc mal écrit que t'as pas vu. En plus, ça garde un code à peu près homogène, et ça permet à toute l'équipe de savoir ce qui change dans le projet.

### 3. Quand est-ce qu'on a un conflit Git, et pourquoi Git le règle pas tout seul ?
**Auteur :** Étudiant 2 (Dorian Cornu)
**Réponse :**
Ça arrive quand deux personnes modifient les mêmes lignes d'un même fichier sur deux branches différentes, ou quand l'une modifie un fichier que l'autre a supprimé. Git sait fusionner quand les changements touchent des endroits différents, mais quand ils tombent au même endroit il ne peut pas deviner quelle version est la bonne. Ça dépend de ce que le code est censé faire, et ça, seul un humain peut le décider.

### 4. Quelle différence entre une correction normale et une correction urgente en prod ?
**Auteur :** Étudiant 1 (Jean Lecaillier)
**Réponse :**
Une correction normale suit le circuit habituel : elle part de la branche de dev, passe en revue et sort avec la prochaine version. Une correction urgente (un hotfix), c'est pour un bug grave en prod qui ne peut pas attendre. Elle part directement de la version stable, on la corrige vite et on la met en ligne tout de suite, sans attendre la prochaine release.

### 5. Pourquoi reporter un hotfix dans la branche de dev ?
**Auteur :** Étudiant 2 (Dorian Cornu)
**Réponse :**
Sinon le bug revient. Si tu corriges seulement en prod, la branche de dev a toujours l'ancien code buggé, et à la prochaine release tu remets le bug en ligne. Il faut donc ramener la correction dans le dev pour que tout le monde reparte sur une base propre.

### 6. À quoi sert une branche de release ?
**Auteur :** Étudiant 2 (Dorian Cornu)
**Réponse :**
C'est une étape intermédiaire avant la mise en prod. On fige les fonctionnalités de la prochaine version, puis on teste et on corrige les derniers petits bugs, pendant que le reste de l'équipe continue à bosser sur la suite dans la branche de dev. Une fois que c'est stable, on la fusionne dans la branche principale.

### 7. Comment GitHub Projects et les Issues aident à s'organiser et à suivre le travail ?
**Auteur :** Étudiant 3 (Gaspard Grignet Le Perron)
**Réponse :**
Les Issues servent à noter chaque tâche, bug ou idée, avec une description, une personne assignée et une discussion. GitHub Projects permet de les ranger dans un tableau du genre « à faire / en cours / fini », donc on voit d'un coup d'œil où en est le projet. Et comme on peut relier une Issue à un commit ou à une pull request, on sait toujours pourquoi un changement a été fait et par qui.

### 8. Comment retrouver d'où vient une modif dans l'historique GitHub ?
**Auteur :** Étudiant 3 (Gaspard Grignet Le Perron)
**Réponse :**
On peut regarder l'historique des commits d'un fichier, ou utiliser le « blame », qui montre pour chaque ligne qui l'a modifiée en dernier et dans quel commit. Depuis ce commit, on remonte à la pull request et à l'Issue liées, ce qui explique le contexte et la raison du changement. En ligne de commande, git log et git blame font la même chose.