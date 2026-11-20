# Recueil des besoins
Projet SAE S5 - Cluster Raspberry Pi (Groupe 3 - INFI3)

## I./ Chapitre 1 – Objectif et portée

### (a) Quels sont la portée et les objectifs généraux ?
**Problématique et enjeux :**
Aujourd'hui, pour lancer un calcul sur les Raspberry Pi 5 du cluster, il faut se connecter manuellement en SSH sur chaque machine. Ce fonctionnement pose plusieurs problèmes concrets au quotidien :
- **Conflits sur les ressources :** sans système de réservation, deux chercheurs peuvent lancer des calculs lourds en même temps sur les mêmes cœurs. Les cartes saturent vite, les temps de calcul sont faussés et les programmes finissent par planter.
- **Difficulté d'accès :** tout le monde ne maîtrise pas Linux, les transferts de fichiers en ligne de commande ou la configuration réseau des nœuds. Cette barrière technique ralentit les utilisateurs qui veulent juste tester leur algorithme.
- **Manque de visibilité :** impossible de savoir d'un coup d'œil qui utilise quoi, pour combien de temps, ni d'arrêter proprement un calcul qui tourne en boucle.
- **Partage du matériel entre les groupes de la promo :** la tour de Raspberry Pi 5 est utilisée par plusieurs groupes d'étudiants en même temps durant le semestre. Si un groupe modifie la configuration globale de SLURM ou lance des tests sans prévenir les autres, il risque de casser l'environnement de travail des voisins.

**Objectifs généraux :**
L'objectif est de créer une interface web simple qui centralise l'accès au cluster et masque toute cette complexité technique. Depuis son navigateur, un utilisateur doit pouvoir voir l'état des Raspberry Pi en temps réel, réserver un créneau (en choisissant un nombre de cœurs ou de nœuds et une durée maximale), lancer son calcul via SLURM, suivre les logs et récupérer ses fichiers de résultats.

### (b) Les intervenants. (Qui est concerné ?)
- **Les chercheurs (utilisateurs) :** ils utilisent le cluster pour leurs calculs. Leur besoin principal est de réserver de la puissance facilement, de lancer leurs programmes Python ou Java sans gérer le réseau, et de récupérer leurs résultats.
- **Les administrateurs :** ils veillent au bon fonctionnement de la plateforme. Ils gèrent le catalogue de calculs disponibles, surveillent l'état matériel des cartes (température, CPU, RAM) et peuvent annuler une réservation ou stopper un calcul bloqué.
- **Les clients (M. Hoguin et M. Dufaud) :** les enseignants qui encadrent la SAE, valident les étapes du projet et vérifient que la solution répond aux attentes techniques et organisationnelles.
- **Les développeurs :** les 5 étudiants du Groupe 3 (INFI3), chargés de concevoir la base de données, l'application web, le lien avec SLURM et la documentation.

### (c) Qu'est-ce qui entre dans cette portée ? Qu'est-ce qui est en dehors ? (Les limites du système.)
**Ce qui est inclus dans le système :**
- La gestion des comptes et des droits (Chercheur et Administrateur).
- Le tableau de bord affichant l'état et la disponibilité des nœuds.
- Le système de réservation par créneau horaire avec blocage des conflits.
- L'envoi sécurisé des programmes vers le frontal, le lancement des jobs SLURM, le suivi des logs et le téléchargement des résultats.
- La gestion d'un catalogue de programmes distribués prêts à être exécutés.

**Ce qui est en dehors (exclu) :**
- L'écriture des algorithmes scientifiques eux-mêmes (le site exécute les scripts fournis par les chercheurs ou vus en TP).
- Toute gestion financière ou facturation des ressources.
- Le câblage physique des cartes et l'installation initiale de l'image Linux sur les cartes SD.

## II./ Chapitre 2 – Terminologie employée / Glossaire

- **Cluster (ferme de calcul) :** ensemble des 5 Raspberry Pi 5 reliés en réseau local qui travaillent ensemble comme une seule machine de calcul.
- **Calcul distribué :** découpage d'un gros calcul en plusieurs petites tâches exécutées en parallèle sur plusieurs cœurs ou plusieurs cartes pour gagner du temps.
- **Frontal (Head Node) :** le Raspberry Pi 5 qui sert de porte d'entrée au cluster. C'est lui qui reçoit les commandes du serveur web et pilote l'ordonnanceur SLURM.
- **Nœud de calcul (Compute Node) :** chacune des 4 cartes Raspberry Pi 5 qui exécutent réellement les calculs distribués.
- **Serveur Web :** le Raspberry Pi 4 qui héberge le site web et la base de données, afin de séparer l'affichage web de la puissance de calcul.
- **SLURM :** logiciel ordonnanceur qui gère la file d'attente, attribue exactement le nombre de cœurs demandés et coupe automatiquement les calculs qui dépassent le temps prévu.
- **Job SLURM :** une tâche de calcul lancée via la commande `sbatch`, identifiée par un numéro (`slurm_job_id`) qui permet de suivre son état ou de l'annuler.
- **MPI / JavaSocket :** outils utilisés dans les programmes Python et Java pour permettre aux différentes cartes d'échanger des données pendant un calcul parallèle.

## III./ Chapitre 3 – Les cas d'utilisation

### (a) Les acteurs principaux et leurs objectifs généraux.
- **Chercheur :** se connecter à la plateforme, vérifier quelles machines sont libres, réserver des cœurs sur une plage horaire, lancer un calcul (depuis le catalogue ou avec son propre script), suivre l'avancement et télécharger les résultats.
- **Administrateur :** ajouter ou retirer des programmes du catalogue, surveiller la santé des Raspberry Pi 5 (charge CPU, mémoire, température) et intervenir sur les réservations ou calculs en cas de blocage.

### (b) Les cas d'utilisation métier (concepts opérationnels).
Au niveau métier, le système répond à deux besoins concrets :
1. **Réserver et consommer de la puissance de calcul :** un chercheur planifie son créneau, exécute son programme sur des ressources qui lui sont réservées sans être gêné par les autres, puis récupère ses sorties.
2. **Superviser et maintenir le cluster :** un administrateur s'assure que les cartes restent opérationnelles, que le catalogue est à jour et que les ressources bloquées sont libérées.

### (c) Les cas d'utilisation système.
Les cas d'utilisation détaillés (avec préconditions, déroulé normal et cas d'erreur) sont décrits dans le `Cahier_des_charges.pdf` :
- **UC-0 :** Lancer une application répartie sur le cluster depuis l'interface web.
- **UC-1 :** Réserver des ressources sur un créneau horaire et exécuter un calcul.
- **UC-2 :** Ajouter un programme distribué au catalogue (Administrateur).
- **UC-3 :** Consulter l'état en temps réel et les caractéristiques matérielles des nœuds.

## IV./ Chapitre 4 – La technologie employée

### (a) Quelles sont les exigences technologiques pour ce système ?
Nous avons séparé l'hébergement web du calcul pur pour ne pas ralentir les nœuds pendant l'exécution des programmes :
- **Serveur web (sur Raspberry Pi 4) :** backend en Python avec le framework Flask (léger et bien adapté au Raspberry Pi) et frontend en HTML, CSS et JavaScript.
- **Base de données (sur Raspberry Pi 4) :** MariaDB avec 6 tables (`Users`, `Machines`, `Catalog_Calculs`, `Reservations`, `Reservation_Machines`, `Executions_Calculs`) pour gérer les comptes, les créneaux et l'historique des jobs.
- **Cluster de calcul (sur les 5 Raspberry Pi 5) :** image Linux commune déployée sur toutes les cartes, ordonnanceur SLURM (`slurmctld` sur le frontal, `slurmd` sur les 4 nœuds), et environnements Python (avec `mpi4py`) et Java (JavaSocket / API Concurrent). Le détail complet de l'installation et de la configuration de SLURM est disponible dans le fichier `docs/Documentation_SLURM.md`.

### (b) Avec quels systèmes ce système s'interfacera-t-il et avec quelles exigences ?
- **Serveur Web (RPI 4) vers Frontal (RPI 5) :** connexion sécurisée en SSH/SCP par échange de clés (sans mot de passe en clair) pour envoyer les scripts, lancer les commandes SLURM (`sbatch`, `squeue`, `scancel`, `sinfo`) et récupérer les fichiers de logs et de résultats.
- **Frontal (RPI 5) vers Nœuds de calcul (RPI 5) :** dialogue interne sur le réseau local du cluster géré par SLURM et MPI/Sockets, ce qui impose une résolution de noms fixe et une heure synchronisée entre toutes les cartes.

## V./ Chapitre 5 – Autres exigences

### (a) Processus de développement
- **i) Qui sont les participants au projet ?**
  Les 5 étudiants du Groupe 3 (INFI3) : ABOUALOU Jihan, BABU Achille, CROCHET Thomas, LAPLUYE Antoine et ZERROUK Achraf, encadrés par M. Dufaud et M. Hoguin.
- **ii) Quelles valeurs devront être privilégiées ?**
  La fiabilité des réservations (zéro conflit entre deux utilisateurs), la simplicité de l'interface (pas besoin de connaître les commandes SLURM) et la sécurité des accès aux cartes.
- **iii) Quels retours ou quelle visibilité sur le projet les utilisateurs et commanditaires souhaitent-ils ?**
  Le projet est suivi à travers 4 jalons intermédiaires. L'ensemble des documents et du code est hébergé sur un dépôt GitHub partagé avec les enseignants pour suivre l'avancement en continu.
- **iv) Que peut-on acheter ? Que doit-on construire ? Qui sont nos concurrents ?**
  - *Existant / Open-source réutilisé :* le matériel fourni par l'IUT (1 RPI 4 et 5 RPI 5), SLURM, MariaDB, Flask et les bibliothèques MPI/Java.
  - *À développer :* la base de données, l'interface web complète, le module de communication SSH/SLURM et les scripts d'intégration des calculs.
  - *Alternatives existantes :* des outils comme Open OnDemand existent dans le monde professionnel, mais ils sont beaucoup trop lourds et complexes à mettre en place sur un petit cluster pédagogique de Raspberry Pi.
- **v) Quels sont les autres exigences du processus ?**
  Un dépôt GitHub organisé proprement (`docs/`, `database/`, `src/`), une documentation technique claire pour l'installation de SLURM et des tests réels sur la tour de Raspberry Pi avant la soutenance.
- **vi) À quelle dépendance le projet est-il soumis ?**
  L'avancement dépend de l'accès physique au cluster en salle serveur, de la mise à disposition de l'image système commune par les profs, et de la bonne coordination entre tous les groupes de la promo pour partager la maquette sans se gêner.

### (b) Règles métier
- **Exclusivité des ressources :** une fois qu'un chercheur a réservé des cœurs ou des nœuds sur un créneau, ces ressources sont bloquées en base de données et personne d'autre ne peut les réserver sur la même plage horaire.
- **Arrêt automatique au dépassement du temps (Timeout) :** si un calcul dépasse la durée maximale prévue lors de la réservation, SLURM le coupe automatiquement pour libérer les machines pour le suivant, tout en sauvegardant les logs déjà générés.
- **Confidentialité des résultats :** chaque utilisateur ne voit et ne télécharge que ses propres calculs et résultats (seul l'administrateur a une vue globale).

### (c) Performances
- Le transfert d'un script et son enregistrement dans la file d'attente SLURM doivent prendre moins de 5 secondes.
- Le site web doit rester fluide (affichage des pages en moins de 2 secondes) et ne jamais bloquer pendant qu'un calcul tourne sur les Raspberry Pi 5.

### (d) Opérations, sécurité, documentation
- **Sécurité :** mots de passe hachés en base de données, connexion SSH vers le frontal via un compte restreint par clés, et aucun accès direct au terminal des Raspberry Pi pour les utilisateurs.
- **Opérations :** les sorties standard et les erreurs de SLURM sont enregistrées automatiquement pour permettre à l'utilisateur de déboguer son script en cas de plantage.
- **Documentation :** le dépôt contient le recueil des besoins, le cahier des charges, le script SQL de la base et la documentation de mise en place de SLURM.

### (e) Utilisation et utilisabilité
L'interface doit être claire et compréhensible immédiatement : l'utilisateur choisit simplement son programme, le nombre de cœurs et la durée, et le site génère tout seul le script SLURM correspondant. L'état des calculs (`En attente`, `En cours`, `Terminé`, `Erreur`) doit être visible sans recharger manuellement les configurations.

### (f) Maintenance et portabilité
L'utilisation de Python/Flask et MariaDB permet de redéployer facilement l'application sur d'autres machines Linux si besoin. La séparation entre le site web, la base de données et SLURM permet aussi d'ajouter de nouveaux nœuds de calcul sans toucher au code de l'interface.

### (g) Questions non résolues ou reportées à plus tard
- La taille maximale autorisée pour l'upload de gros fichiers de données sera fixée lors des tests sur le matériel au Jalon 3.
- L'envoi d'un mail automatique à la fin d'un calcul long est prévu en bonus si le planning le permet.

## VI./ Chapitre 6 – Recours humain, questions juridiques, politiques, organisationnelles.

### (a) Quel est le recours humain au fonctionnement du système ?
Même si SLURM automatise l'exécution des calculs, il faut toujours un administrateur pour ajouter de nouveaux programmes validés dans le catalogue, gérer d'éventuels soucis de comptes utilisateurs et intervenir si une carte plante ou chauffe anormalement.

### (b) Quelles sont les exigences juridiques et politiques ?
Le site ne stocke que les informations strictement nécessaires (nom, mail, mot de passe haché) conformément au RGPD, et respecte les règles réseau de l'IUT en gardant les nœuds de calcul isolés derrière le frontal.

### (c) Quelles sont les conséquences humaines de la réalisation du système ?
Les chercheurs gagnent du temps et n'ont plus à se battre en SSH pour savoir si une carte est libre. De leur côté, les enseignants et administrateurs ont moins de maintenance à faire suite à de fausses manipulations sur les Raspberry Pi.

### (d) Quels sont les besoins en formation ?
Notre équipe doit monter en compétence sur la configuration de SLURM, MPI (`mpi4py`) et JavaSocket pendant les TP du semestre. Pour les utilisateurs finaux, aucune formation technique n'est nécessaire, une simple aide rapide sur le site suffira.

### (e) Quelles sont les hypothèses et les dépendances affectant l'environnement humain ?
- **Organisation entre tous les groupes :** comme le cluster physique de Raspberry Pi 5 est partagé entre tous les groupes de la promo, il est indispensable de se mettre d'accord sur des règles communes : définir un planning d'utilisation de la tour, utiliser chacun un dossier personnel dédié (ex. `/home/groupe3`) et des ports distincts pour nos serveurs web, ne jamais modifier la configuration globale de SLURM sans l'accord des autres groupes, et nettoyer nos fichiers de test après chaque séance.
- **Disponibilité des encadrants :** le bon avancement du projet s'appuie sur les retours réguliers des enseignants.
