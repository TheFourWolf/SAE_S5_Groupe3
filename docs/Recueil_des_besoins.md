# Recueil des besoins
Projet SAE S5 - Cluster Raspberry Pi (Groupe INFI3)

## 1. Objectif et portée

### 1.1 Problématique
Actuellement, l'accès aux cartes Raspberry Pi 5 du cluster se fait manuellement en SSH. Les chercheurs doivent vérifier eux-mêmes si des machines sont libres avant de lancer un programme, ce qui entraîne des risques de conflits d'accès sur les mêmes cœurs et complique le suivi des calculs ainsi que la récupération des résultats.

### 1.2 Portée et objectifs généraux
Le système a pour objectif de centraliser l'accès et l'utilisation du cluster via une interface web. Elle doit permettre de visualiser l'état des nœuds en temps réel, de réserver un créneau (nombre de cœurs ou de nœuds + durée maximale), de soumettre un programme distribué via SLURM, de suivre ses logs d'exécution et de télécharger les fichiers de résultats.

### 1.3 Intervenants
- Les chercheurs (utilisateurs) : consultent la disponibilité du cluster, réservent des ressources, lancent leurs calculs et récupèrent les résultats.
- Les administrateurs : gèrent le catalogue des programmes disponibles, supervisent l'état matériel des machines et modèrent les réservations ou calculs bloqués.
- Les clients : M. Hoguin et M. Dufaud.
- Les développeurs : les 5 étudiants du groupe INFI3.

### 1.4 Limites du système (inclus / exclus)
- Inclus dans le système : gestion des utilisateurs et des rôles, calendrier de réservation des ressources, communication SSH sécurisée avec le frontal, soumission et annulation de tâches SLURM, suivi des logs et téléchargement des résultats.
- Hors périmètre (exclus) : le développement des algorithmes scientifiques eux-mêmes (fournis par les chercheurs ou réalisés en TP) ainsi que toute gestion financière ou facturation.

## 2. Terminologie employée

- Calcul distribué : découpage d'un calcul lourd en plusieurs sous-tâches exécutées en parallèle sur plusieurs machines.
- Cluster (ferme de calcul) : ensemble des 5 Raspberry Pi 5 reliés en réseau local (1 frontal + 4 nœuds de calcul).
- Nœud (Compute Node) : une carte Raspberry Pi 5 dédiée à l'exécution des calculs.
- Frontal : le Raspberry Pi 5 d'entrée du cluster, hébergeant le contrôleur SLURM et recevant les commandes SSH depuis le serveur web.
- SLURM : ordonnanceur open-source chargé de gérer la file d'attente, l'allocation des cœurs demandés et l'arrêt automatique des calculs dépassant la durée prévue.
- MPI / JavaSocket : outils et bibliothèques utilisés dans les programmes pour faire communiquer les processus entre eux pendant l'exécution.

## 3. Les cas d'utilisation

### 3.1 Acteurs principaux et objectifs
- Chercheur : se connecter, consulter l'état des machines, réserver des cœurs ou des nœuds sur un créneau, lancer un calcul (Python ou Java), suivre les logs et télécharger les résultats.
- Administrateur : ajouter ou supprimer des programmes dans le catalogue, surveiller l'état matériel des RPI 5 (CPU, RAM, température), annuler une réservation ou stopper un calcul bloqué.

### 3.2 Liste des cas d'utilisation
- UC-0 : Lancer une application répartie sur le cluster depuis l'interface web (cas général).
- UC-1 : Réserver des ressources sur un créneau horaire et exécuter un calcul.
- UC-2 : Ajouter un programme distribué au catalogue (Administrateur).
- UC-3 : Consulter l'état en temps réel et les caractéristiques matérielles des nœuds.

Le détail complet des scénarios (préconditions, déroulé nominal et exceptions) figure dans le document `Cahier_des_charges.pdf`.

## 4. La technologie employée

### 4.1 Exigences technologiques
- Serveur web (RPI 4) : backend développé en Python avec le framework Flask, interface frontend en HTML, CSS et JavaScript.
- Base de données : MariaDB hébergée sur le RPI 4 (6 tables : Users, Machines, Catalog_Calculs, Reservations, Reservation_Machines et Executions_Calculs).
- Système d'exploitation : image Linux légère commune déployée sur les 5 Raspberry Pi 5.
- Langages supportés pour les calculs : Python (avec MPI / mpi4py) et Java (avec JavaSocket et l'API Concurrent).

### 4.2 Interfaces externes
- Serveur web (RPI 4) vers Frontal (RPI 5) : communication sécurisée par échange de clés SSH pour transférer les fichiers et exécuter les commandes SLURM (`sbatch`, `squeue`, `scancel`, `sinfo`).
- Frontal (RPI 5) vers Nœuds de calcul (RPI 5) : pilotage interne via les démons SLURM (`slurmctld` sur le frontal et `slurmd` sur les nœuds).

## 5. Autres exigences

### 5.1 Processus de développement
- Participants : les 5 étudiants du groupe INFI3.
- Valeurs privilégiées : simplicité de prise en main pour les chercheurs, fiabilité des réservations et sécurité des accès.
- Suivi : projet découpé en 4 jalons intermédiaires avant le rendu final.
- Dépendances : disponibilité de la tour de Raspberry Pi 5 en salle serveur et mise à disposition de l'image système commune.

### 5.2 Règles métier
- Exclusivité des ressources : les cœurs ou nœuds réservés sur un créneau horaire sont bloqués pour l'utilisateur concerné et ne peuvent pas être alloués à un autre chercheur en même temps.
- Temps maximal (Timeout) : tout calcul dépassant la durée maximale renseignée lors de la réservation est arrêté automatiquement par SLURM, tout en conservant les logs générés jusque-là.

### 5.3 Sécurité, opérations et utilisabilité
- Sécurité : mots de passe hachés en base de données, séparation des droits par rôle (chercheur / admin) et aucun accès SSH direct des utilisateurs aux Raspberry Pi 5.
- Utilisabilité : application accessible directement depuis un navigateur web standard sans installation préalable côté client.
- Maintenance : code versionné sur GitHub accompagné de sa documentation technique.

## 6. Aspects humains et organisationnels

### 6.1 Recours humain
Un administrateur est nécessaire pour maintenir le catalogue des programmes à jour, gérer les comptes si besoin et intervenir en cas d'alerte matérielle sur un nœud.

### 6.2 Contraintes organisationnelles
Le cluster de Raspberry Pi 5 étant mutualisé entre plusieurs groupes d'étudiants durant le semestre, il est indispensable de conserver la configuration système commune et de respecter strictement les créneaux de réservation.

### 6.3 Besoins en formation
L'équipe doit monter en compétence sur la configuration et l'administration de SLURM ainsi que sur la programmation parallèle en MPI et JavaSocket au fil des TP.
