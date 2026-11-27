# Plateforme de réservation et d'exécution de calculs distribués
Projet SAE S5 - Département Informatique (IUT de Vélizy-Rambouillet)

**Groupe :** Groupe 3 (INFI3)  
**Membres :** ABOUALOU Jihan, BABU Achille, CROCHET Thomas, LAPLUYE Antoine, ZERROUK Achraf  
**Tuteurs / Clients :** M. Hoguin & M. Dufaud

## Présentation
L'objectif de ce projet est de créer une application web qui permet à des chercheurs de réserver facilement de la puissance de calcul (des cœurs ou des nœuds complets) et de lancer leurs programmes distribués sur un cluster de Raspberry Pi 5 géré par SLURM, sans avoir à se connecter manuellement en SSH sur chaque machine.

## Architecture matérielle et logicielle
Nous avons séparé l'hébergement du site web de la partie calcul pur pour ne pas ralentir les Raspberry Pi pendant l'exécution des programmes:
- **Serveur web (1 x Raspberry Pi 4)** : héberge l'interface web (HTML, CSS, JavaScript), le serveur backend en Python (Flask) ainsi que la base de données MariaDB.
- **Nœud frontal (1 x Raspberry Pi 5)** : sert de porte d'entrée au cluster. Il reçoit les instructions en SSH depuis le serveur web et gère la file d'attente via l'ordonnanceur SLURM.
- **Ferme de calcul (4 x Raspberry Pi 5)** : exécute les programmes parallèles en Python (avec MPI) ou en Java (JavaSocket / API Concurrent).

## Organisation du dépôt
- `docs/` : recueil des besoins, cahier des charges complet et documentation technique d'installation de SLURM.
- `database/` : script SQL et schéma de la base de données MariaDB (6 tables).
- `src/` : code source de l'application web et des programmes de calcul.

## Lien avec les 6 compétences du BUT Informatique

| Compétence | Ce que nous mettons en place dans le projet | Dossiers / Fichiers |
| :--- | :--- | :--- |
| **C1 — Réaliser** | Développement de l'interface web, du serveur Python/Flask, du connecteur SSH et des scripts de calcul parallèle (MPI / JavaSocket). | `src/` |
| **C2 — Optimiser** | Découpage des tâches en parallèle sur plusieurs cœurs/nœuds, suivi de la charge CPU/RAM et réduction des temps de calcul. | `src/`, `docs/Cahier_des_charges.pdf` |
| **C3 — Administrer** | Mise en réseau des 6 Raspberry Pi, installation et configuration de SLURM (`slurmctld` / `slurmd`) et sécurisation des échanges SSH par clés. | `docs/Documentation_SLURM.md` |
| **C4 — Gérer** | Modélisation et gestion de la base de données relationnelle MariaDB, blocage des conflits de réservation et sauvegarde des logs d'exécution. | `database/` |
| **C5 — Conduire** | Pilotage agile (Scrum en 4 sprints / jalons), rédaction du recueil des besoins (plan d'Alistair Cockburn) et du cahier des charges, analyse des enjeux et suivi du backlog. | `docs/Recueil_des_besoins.md`, `docs/Cahier_des_charges.pdf` |
| **C6 — Collaborer** | Travail en équipe au sein du Groupe 3, entente avec les autres groupes de la promo pour le partage matériel du cluster, suivi sur GitHub et échanges avec les profs. | Dépôt GitHub, `docs/Recueil_des_besoins.md` |

## Répartition de l'équipe (Groupe 3)
Pour bien couvrir l'ensemble des aspects techniques et organisationnels tout en travaillant ensemble sur les choix d'architecture, chacun pilote un pôle principal :

| Membre | Rôle principal | Missions concrètes |
| :--- | :--- | :--- |
| **ABOUALOU Jihan** | Documentation | Suivi des jalons, rédaction du recueil des besoins et du cahier des charges. |
| **BABU Achille** | Calcul distribué & Tests | Développement des programmes parallèles (Python/MPI et JavaSocket), liaison avec les commandes `sbatch` / `squeue` et tests sur la tour de Raspberry Pi. |
| **CROCHET Thomas** | Réseau & Administration SLURM | Configuration système et réseau des Raspberry Pi, installation de SLURM sur le frontal et les nœuds, gestion des clés SSH & Documentation_SLURM et coordination avec les autres groupes de la promo. |
| **LAPLUYE Antoine** | Interface Web & Ergonomie | Création des pages web (HTML/CSS/JS), tableau de bord de suivi de l'état des machines et affichage des résultats et logs. |
| **ZERROUK Achraf** | Base de données & Backend | Création et gestion de la base MariaDB (6 tables), développement du serveur Flask et logique de vérification des créneaux de réservation. |
