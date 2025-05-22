# HyperSweep - Nettoyeur Automatique de Fichiers Temporaires (Windows)

**HyperSweep** est un outil PowerShell pour automatiser le nettoyage de fichiers temporaires, les organiser par catégorie, et les gérer via une corbeille temporaire avec possibilité de restauration. Il supporte l'exécution via fork, thread ou subshell.

---

## Fonctionnalités

- Suppression automatique des fichiers expirés dans `Desktop/tmp`
- Classement automatique par type (Documents, Images, etc.)
- Système de corbeille temporaire avant suppression définitive
- Restauration de fichiers supprimés par nom
- Configuration interactive (durée et unité)
- Journalisation de chaque action avec horodatage et nom d’utilisateur
- Exécution via :
  - `-f` : Fork (nouveau processus)
  - `-t` : Thread (tâche en arrière-plan)
  - `-s` : Subshell (dans la même fenêtre)

---

## Structure du Projet

```

HyperSweep/
├── Main-Cleaner.ps1           # Script principal
├── Test.ps1                   # Script de test de scénarios
├── logs/                      # Dossier des journaux
└── scripts/
├── Cleaner-Tmp.ps1
├── Empty-Trash.ps1
├── Empty-Trash-Instant.ps1
├── List-Trash.ps1
├── New-TmpFile.ps1
└── Restore-FromTrash.ps1

````

---

## Utilisation

```powershell
.\Main-Cleaner.ps1 -a <action> [options]
````

### Actions (`-a`)

| Action         | Description                                         |
| -------------- | --------------------------------------------------- |
| `clean`        | Lancer le nettoyage automatique (interactif)        |
| `empty`        | Vider la corbeille des fichiers de plus de 30 jours |
| `emptyInstant` | Vider immédiatement la corbeille                    |
| `listTrash`    | Lister les fichiers dans la corbeille               |
| `restore`      | Restaurer un fichier supprimé (`-n` requis)         |
| `newFile`      | Créer un fichier temporaire (`-n` requis)           |
| `help`         | Afficher l’aide                                     |

### Options

| Option | Description                                          |
| ------ | ---------------------------------------------------- |
| `-n`   | Nom du fichier (avec `newFile` ou `restore`)         |
| `-l`   | Dossier de log (par défaut : `./logs`)               |
| `-f`   | Exécution via fork (nouveau processus PowerShell)    |
| `-t`   | Exécution via thread (job en arrière-plan)           |
| `-s`   | Exécution dans un subshell (même session PowerShell) |
| `-r`   | Réinitialiser les paramètres (admin requis)          |
| `-h`   | Afficher l’aide                                      |

### Exemples

```powershell
.\Main-Cleaner.ps1 -a clean
.\Main-Cleaner.ps1 -a newFile -n exemple.txt
.\Main-Cleaner.ps1 -a restore -n exemple.txt
.\Main-Cleaner.ps1 -a clean -t
```

---

## Scénarios de Test

Exécuter le menu de test :

```powershell
.\Test.ps1
```

Choisissez un scénario :

* **Scénario 1 (Léger)** : Crée 1 fichier, exécute le nettoyage via subshell
* **Scénario 2 (Moyen)** : Crée 3 fichiers, exécute via fork
* **Scénario 3 (Lourd)** : Crée 5 fichiers, exécute via thread avec journalisation complète

Chaque scénario teste la création, le nettoyage, la gestion de la corbeille et la restauration.

