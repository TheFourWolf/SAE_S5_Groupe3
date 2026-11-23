# Documentation technique — Mise en place et fonctionnement de SLURM
Projet SAE S5 - Cluster Raspberry Pi (Groupe 3 - INFI3)

## 1. Présentation générale et rôle de SLURM
Dans notre architecture (définie dans le *Recueil des besoins* et le *Cahier des charges*), l'application web hébergée sur le **Raspberry Pi 4** ne lance jamais les calculs directement. Elle délègue cette tâche à **SLURM** (*Simple Linux Utility for Resource Management*), installé sur la ferme de calcul composée de **5 Raspberry Pi 5**.

SLURM joue le rôle de chef d'orchestre sur le cluster :
- Il centralise les demandes de calcul dans une file d'attente.
- Il garantit qu'un cœur ou un nœud réservé par un chercheur n'est pas utilisé par quelqu'un d'autre en même temps.
- Il coupe automatiquement les programmes qui dépassent la durée maximale prévue (`Timeout`), évitant ainsi qu'un script bloqué ne paralyse la machine.

### Répartition des rôles sur le matériel
| Machine | Nom d'hôte | Rôle dans le cluster | Services actifs |
| :--- | :--- | :--- | :--- |
| **1 × Raspberry Pi 4** | `rpi4-web` | Serveur applicatif (site Flask + base MariaDB) | Client SSH vers le frontal |
| **1 × Raspberry Pi 5** | `rpi5-frontal` | **Nœud frontal** : point d'entrée du cluster et contrôleur | `slurmctld`, `munge`, serveur SSH |
| **4 × Raspberry Pi 5** | `rpi5-node1` à `4` | **Nœuds de calcul** : exécutent les programmes parallèles | `slurmd`, `munge`, Python/MPI, Java |

---

## 2. Préparation du réseau et des machines
Avant d'installer SLURM, toutes les cartes du cluster doivent pouvoir communiquer par leur nom et partager exactement la même heure.

### 2.1 Configuration de la résolution des noms (`/etc/hosts`)
SLURM identifie chaque machine par son nom d'hôte (`hostname`). Il faut donc renseigner les adresses IP fixes de l'ensemble du cluster dans le fichier `/etc/hosts` sur **chacun des 5 Raspberry Pi 5** :

```bash
sudo nano /etc/hosts
```

Ajouter les lignes suivantes :
```text
192.168.1.10   rpi5-frontal
192.168.1.11   rpi5-node1
192.168.1.12   rpi5-node2
192.168.1.13   rpi5-node3
192.168.1.14   rpi5-node4
```

### 2.2 Synchronisation horaire (NTP)
Si l'horloge d'un nœud a quelques secondes de décalage avec le frontal, SLURM refuse les communications par sécurité. On active la synchronisation automatique sur **toutes les cartes** :

```bash
sudo timedatectl set-ntp true
timedatectl status
```
*Vérification :* la ligne `System clock synchronized` doit afficher `yes`.

### 2.3 Isolation de notre groupe sur la maquette partagée
La tour de Raspberry Pi 5 étant partagée entre plusieurs groupes de la promotion (exigence de *coexistence* ISO/IEC 25010), nous utilisons un répertoire dédié `/home/groupe3` afin de ne pas mélanger nos scripts et nos résultats avec ceux des autres équipes.

---

## 3. Installation des paquets nécessaires
Sur **les 5 Raspberry Pi 5** (frontal et nœuds de calcul), on met à jour le système et on installe SLURM, le service d'authentification MUNGE, ainsi que les bibliothèques nécessaires aux calculs distribués en Python (MPI) et en Java :

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y slurm-wlm munge libmunge-dev python3-mpi4py openmpi-bin default-jdk
```

---

## 4. Sécurisation des échanges internes avec MUNGE
Pour éviter qu'une machine extérieure ne puisse envoyer de fausses commandes aux nœuds de calcul, SLURM utilise **MUNGE**. Ce service chiffre et signe les messages entre le frontal et les nœuds grâce à une clé secrète partagée.

### 4.1 Génération et envoi de la clé depuis le frontal (`rpi5-frontal`)
Sur le nœud frontal uniquement, on génère la clé secrète, on restreint ses droits d'accès, puis on l'envoie vers les 4 nœuds de calcul :

```bash
sudo /usr/sbin/create-munge-key -f
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key

for node in rpi5-node1 rpi5-node2 rpi5-node3 rpi5-node4; do
    scp /etc/munge/munge.key pi@$node:/tmp/munge.key
done
```

### 4.2 Mise en place de la clé sur les 4 nœuds (`rpi5-node1` à `rpi5-node4`)
Sur chaque nœud de calcul, on place la clé dans `/etc/munge/`, on applique les bonnes permissions et on redémarre le service :

```bash
sudo mv /tmp/munge.key /etc/munge/munge.key
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl restart munge
```

*Vérification :* depuis le frontal, on teste qu'un jeton généré localement est bien reconnu par un nœud :
```bash
munge -n | ssh rpi5-node1 unmunge
```
La commande doit retourner `STATUS: Success (0)`.

---

## 5. Configuration de SLURM (`slurm.conf`)
Le comportement du cluster est défini dans le fichier `/etc/slurm/slurm.conf`. Ce fichier doit être **strictement identique** sur le frontal et sur les 4 nœuds de calcul.

Chaque Raspberry Pi 5 possède **4 cœurs CPU** et **8 Go de RAM** (on déclare `7500` Mo utilisables afin de laisser de la mémoire au système d'exploitation).

### 5.1 Contenu du fichier `/etc/slurm/slurm.conf`
```ini
# Identification du cluster et du contrôleur principal
ClusterName=cluster_rpi5
SlurmctldHost=rpi5-frontal

# Authentification des échanges
AuthType=auth/munge
CryptoType=crypto/munge
SlurmUser=slurm
SlurmdUser=root

# Ports réseau et dossiers de travail internes
SlurmctldPort=6817
SlurmdPort=6818
StateSaveLocation=/var/spool/slurmctld
SlurmdSpoolDir=/var/spool/slurmd
SlurmctldPidFile=/run/slurmctld.pid
SlurmdPidFile=/run/slurmd.pid

# Fichiers de journaux (logs système)
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

# Allocation fine par cœur (CR_Core) et gestion des timeouts
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300

# Déclaration des 4 nœuds de calcul (4 cœurs par carte = 16 cœurs au total)
NodeName=rpi5-node[1-4] CPUs=4 RealMemory=7500 State=UNKNOWN

# Partition par défaut regroupant les 4 nœuds (durée max de sécurité : 2h)
PartitionName=debug Nodes=rpi5-node[1-4] Default=YES MaxTime=02:00:00 State=UP
```

### 5.2 Déploiement et démarrage des démons SLURM
1. **Copier la configuration du frontal vers les 4 nœuds :**
   ```bash
   for node in rpi5-node1 rpi5-node2 rpi5-node3 rpi5-node4; do
       sudo scp /etc/slurm/slurm.conf pi@$node:/tmp/slurm.conf
       ssh pi@$node "sudo mv /tmp/slurm.conf /etc/slurm/slurm.conf && sudo chown root:root /etc/slurm/slurm.conf"
   done
   ```

2. **Démarrer le contrôleur sur le frontal (`rpi5-frontal`) :**
   ```bash
   sudo mkdir -p /var/spool/slurmctld /var/log/slurm
   sudo chown -R slurm:slurm /var/spool/slurmctld /var/log/slurm
   sudo systemctl enable slurmctld
   sudo systemctl restart slurmctld
   ```

3. **Démarrer le démon d'exécution sur chacun des 4 nœuds (`rpi5-node1` à `rpi5-node4`) :**
   ```bash
   sudo mkdir -p /var/spool/slurmd /var/log/slurm
   sudo chown -R slurm:slurm /var/log/slurm
   sudo systemctl enable slurmd
   sudo systemctl restart slurmd
   ```

*Vérification :* sur le frontal, la commande `sinfo` doit afficher les 4 nœuds dans l'état `idle` (disponibles). Si un nœud apparaît bloqué en `drain` ou `down`, on le remet en service avec :
```bash
sudo scontrol update NodeName=rpi5-node[1-4] State=RESUME
```

---

## 6. Liaison entre le Serveur Web (RPI 4) et le Frontal (RPI 5)
Pour respecter l'exigence de sécurité du *Recueil des besoins* (aucun utilisateur n'a accès directement au terminal des Raspberry Pi), seul le backend Python/Flask du Raspberry Pi 4 communique avec le frontal via une connexion **SSH authentifiée par clé asymétrique**.

### Mise en place de la clé SSH sur le serveur web (`rpi4-web`)
```bash
# Génération de la clé dédiée à l'application
ssh-keygen -t ed25519 -f ~/.ssh/id_cluster_groupe3 -N ""

# Autorisation de la clé sur le frontal
ssh-copy-id -i ~/.ssh/id_cluster_groupe3.pub pi@rpi5-frontal

# Création de l'arborescence de travail du Groupe 3 sur le frontal
ssh -i ~/.ssh/id_cluster_groupe3 pi@rpi5-frontal "mkdir -p /home/groupe3/{scripts,inputs,outputs,logs}"
```

---

## 7. Fonctionnement : comment l'application pilote SLURM
Lorsqu'un chercheur utilise l'interface web (cas d'utilisation `UC-0`, `UC-1`, `UC-3` du *Cahier des charges*), le backend Flask traduit ses actions en commandes SLURM exécutées à distance via SSH :

| Action sur le site Web | Commande exécutée sur le frontal | Rôle et exploitation par le site |
| :--- | :--- | :--- |
| **Afficher l'état du cluster (`UC-3`)** | `sinfo -N -o "%N %C %m %T"` | Récupère le nom, les cœurs libres/occupés, la RAM et l'état de chaque nœud. |
| **Lancer un calcul (`UC-0` / `UC-1`)** | `sbatch /home/groupe3/scripts/job_<id>.sh` | Envoie le calcul dans la file et récupère son identifiant unique (`slurm_job_id`). |
| **Suivre l'avancement** | `squeue -j <slurm_job_id> -h -o "%T %M"` | Permet de mettre à jour le statut (`PENDING`, `RUNNING`, `COMPLETED`) en base. |
| **Stopper un calcul bloqué** | `scancel <slurm_job_id>` | Interrompt immédiatement le programme sur tous les nœuds alloués. |

### Exemple de script `sbatch` généré par le serveur Flask
Si un chercheur réserve **2 nœuds** et **8 cœurs** pendant **15 minutes maximum** pour exécuter un calcul Python MPI, le serveur web génère automatiquement ce fichier avant de le soumettre avec `sbatch` :

```bash
#!/bin/bash
#SBATCH --job-name=groupe3_exec_42
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --time=00:15:00
#SBATCH --output=/home/groupe3/logs/exec_42.out
#SBATCH --error=/home/groupe3/logs/exec_42.err

mpirun -np 8 python3 /home/groupe3/scripts/calcul_pi.py /home/groupe3/inputs/data_42.txt > /home/groupe3/outputs/res_42.txt
```
*Note : si le programme ne s'est pas terminé au bout des 15 minutes (`--time=00:15:00`), SLURM l'arrête automatiquement pour libérer les ressources pour le chercheur suivant, tout en conservant les logs générés dans `exec_42.out` et `exec_42.err`.*

---

## 8. Résolution des pannes fréquentes
- **Un nœud passe en état `down*` dans `sinfo` :** vérifier que les services `slurmd` et `munge` sont actifs sur la carte concernée (`sudo systemctl status slurmd munge`) et vérifier l'heure système (`timedatectl`).
- **Erreur `Invalid credential` lors de la soumission :** la clé `/etc/munge/munge.key` diffère entre le frontal et un nœud de calcul ; redéployer la clé et redémarrer `munge`.
- **Inspecter les erreurs SLURM :**
  - Logs du frontal : `sudo tail -n 50 /var/log/slurm/slurmctld.log`
  - Logs d'un nœud : `sudo tail -n 50 /var/log/slurm/slurmd.log`
