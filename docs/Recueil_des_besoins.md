# Recueil des besoins
Projet SAE S5 - Cluster Raspberry Pi (Groupe INFI3)

Document réalisé dans le cadre du cours d'Analyse des Besoins (M. Dufaud) selon le plan en 6 chapitres d'Alistair Cockburn.


## 1. Objectif et portée du projet

### Objectifs généraux
L'objectif est de mettre en place une interface web permettant de gérer et lancer des calculs distribués sur le cluster de Raspberry Pi 5 sans avoir à se connecter manuellement en SSH sur chaque machine. Concrètement, le site doit permettre de voir l'état des cartes, réserver un créneau (en choisissant un nombre de cœurs ou de nœuds et une durée max), envoyer son programme, suivre les logs et récupérer les résultats.

### Intervenants
- Les chercheurs (utilisateurs) : ils consultent les disponibilités, réservent des ressources et lancent leurs calculs.
- Les administrateurs : ils gèrent la liste des programmes disponibles, surveillent l'état des machines et peuvent annuler une réservation ou un calcul bloqué.
- Les clients : M. Hoguin et M. Dufaud.
- L'équipe projet : les 5 étudiants du groupe INFI3.

### Périmètre et limites
Ce qui est pris en charge par notre plateforme : la gestion des comptes, le calendrier de réservation, la liaison SSH entre le serveur web et le frontal, l'envoi des tâches à SLURM et la récupération des fichiers de sortie.
Ce qui est hors périmètre : l'écriture des algorithmes de calcul scientifique eux-mêmes (qui sont fournis par les utilisateurs ou réalisés en TP) ainsi que toute notion de facturation ou de gestion financière.


## 2. Glossaire

- Calcul distribué : découpage d'un calcul lourd en plusieurs sous-tâches exécutées en parallèle sur plusieurs machines.
- Cluster (ferme de calcul) : ensemble des 5 Raspberry Pi 5 reliés en réseau local (1 frontal + 4 nœuds de calcul).
- Nœud : une carte Raspberry Pi 5 dédiée à l'exécution des calculs.
- Frontal : le Raspberry Pi 5 qui fait le lien entre notre serveur web (RPI 4) et les nœuds de calcul, et sur lequel tourne le contrôleur SLURM.
- SLURM : ordonnanceur chargé de gérer la file d'attente, d'allouer les cœurs demandés et de stopper les calculs qui dépassent le temps prévu.
- MPI / JavaSocket : outils utilisés dans les programmes pour faire communiquer les processus entre eux pendant le calcul.


## 3. Cas d'utilisation

### Acteurs et besoins principaux
- Le chercheur a besoin de se connecter, vérifier quelles machines sont libres, réserver un créneau, lancer un programme Python ou Java, voir l'avancement via les logs et télécharger son résultat.
- L'administrateur a besoin d'ajouter de nouveaux programmes au catalogue, voir l'état matériel des RPI 5 (CPU, RAM, température) et intervenir en cas de blocage.

### Liste des cas d'utilisation identifiés
- UC-0 : Lancer une application répartie sur le cluster depuis l'interface web (cas général).
- UC-1 : Réserver des ressources sur un créneau horaire et exécuter un calcul.
- UC-2 : Ajouter un programme distribué au catalogue (Administrateur).
- UC-3 : Consulter l'état en temps réel et les caractéristiques des nœuds.

Le détail complet des scénarios (étapes, préconditions et gestion des erreurs) est décrit dans le fichier `Cahier_des_charges.pdf`.


## 4. Technologies employées

### Choix techniques
- Serveur web (RPI 4) : backend développé en Python avec Flask, front en HTML, CSS et JavaScript.
- Base de données : MariaDB hébergée sur le RPI 4 (composée de 6 tables : Users, Machines, Catalog_Calculs, Reservations, Reservation_Machines et Executions_Calculs).
- Système : utilisation d'une image Linux légère commune sur tous les Raspberry Pi 5 pour garder un environnement identique entre les groupes.
- Langages supportés pour les calculs : Python (avec MPI) et Java (avec JavaSocket et l'API Concurrent).

### Interfaces avec l'externe
Le serveur web (RPI 4) communique avec le RPI 5 frontal via SSH (authentification par clés) pour transférer les fichiers et lancer les commandes SLURM (`sbatch`, `squeue`, `scancel`, `sinfo`). Le frontal communique ensuite avec les 4 nœuds de calcul via les services SLURM (`slurmctld` et `slurmd`).



## 5. Autres exigences

### Organisation du développement
Le projet est réalisé par les 5 membres du groupe INFI3 et découpé en 4 jalons avant le rendu final. L'accent est mis sur la simplicité de l'interface web et la fiabilité des réservations. Le développement dépend de l'accès à la tour de RPI 5 en salle serveur et de la mise à disposition de l'image système commune.

### Règles métier
- Lorsqu'un chercheur réserve un certain nombre de cœurs ou de nœuds sur un créneau, ces ressources lui sont exclusivement réservées pendant cette période.
- Si un calcul dépasse la durée maximale indiquée lors du lancement, SLURM l'arrête automatiquement pour ne pas bloquer les autres utilisateurs, tout en conservant les logs générés jusque-là.

### Sécurité et utilisation
Les mots de passe sont hachés en base de données et les accès sont séparés selon le rôle (chercheur ou admin). Les utilisateurs n'ont jamais d'accès SSH direct aux Raspberry Pi 5, tout passe par le serveur web. L'interface est accessible directement depuis un navigateur sans rien installer sur le poste client.



## 6. Aspects humains et organisationnels

- Exploitation : un administrateur est nécessaire pour maintenir le catalogue de calculs à jour et vérifier l'état matériel du cluster en cas d'alerte.
- Contraintes matérielles : les Raspberry Pi 5 étant partagés entre plusieurs groupes d'étudiants sur le semestre, il est indispensable de respecter la configuration système commune et les créneaux de réservation.
- Compétences : l'équipe doit monter en compétence sur la configuration de SLURM ainsi que sur la programmation distribuée avec MPI et JavaSocket au fil des TP.
