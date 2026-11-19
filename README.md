# Plateforme de réservation et d'exécution de calculs distribués
Projet SAE S5 - Département Informatique (IUT de Vélizy-Rambouillet)

Groupe : INFI3  
Membres : ABOUALOU Jihan, BABU Achille, CROCHET Thomas, LAPLUYE Antoine, ZERROUK Achraf  
Clients / Tuteurs : M. Hoguin & M. Dufaud

## Présentation
Ce projet consiste à développer une plateforme web permettant à des chercheurs de réserver des ressources de calcul (cœurs ou nœuds complets) et de lancer des applications distribuées sur un cluster de Raspberry Pi 5 piloté par SLURM.

## Architecture du système
- Serveur web (1 x RPI 4) : héberge l'interface web (HTML/CSS/JS), le backend en Python (Flask) et la base de données MariaDB.
- Nœud frontal (1 x RPI 5) : reçoit les commandes en SSH depuis le serveur web et gère la file d'attente via l'ordonnanceur SLURM.
- Ferme de calcul (4 x RPI 5) : exécute les programmes parallèles en Python (MPI) ou Java (JavaSocket / API Concurrent).

## Contenu du dépôt
- `docs/` : cahier des charges, recueil des besoins et documentation technique SLURM.
- `database/` : schéma de la base de données MariaDB.
- `src/` : code source de l'application (à venir pour les prochains jalons).
