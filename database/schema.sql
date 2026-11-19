-- Base de données MariaDB - Projet SAE S5 (Groupe INFI3)

CREATE DATABASE IF NOT EXISTS cluster_rpi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cluster_rpi;

CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'chercheur',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse_ip VARCHAR(45) NOT NULL UNIQUE,
    nb_coeurs INT NOT NULL,
    ram_go INT NOT NULL,
    statut VARCHAR(50) NOT NULL DEFAULT 'Disponible'
);

CREATE TABLE Catalog_Calculs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(150) NOT NULL,
    description TEXT,
    fichier_script VARCHAR(255) NOT NULL,
    langage VARCHAR(50) NOT NULL,
    nb_noeuds_recommandes INT,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES Users(id) ON DELETE SET NULL
);

CREATE TABLE Reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE Reservation_Machines (
    reservation_id INT NOT NULL,
    machine_id INT NOT NULL,
    nb_coeurs_reserves INT NOT NULL,
    PRIMARY KEY (reservation_id, machine_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(id) ON DELETE CASCADE,
    FOREIGN KEY (machine_id) REFERENCES Machines(id) ON DELETE CASCADE
);

CREATE TABLE Executions_Calculs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    calcul_id INT NOT NULL,
    slurm_job_id VARCHAR(50),
    statut VARCHAR(50) NOT NULL DEFAULT 'En attente',
    logs_execution TEXT,
    fichier_resultat VARCHAR(255),
    date_lancement TIMESTAMP NULL,
    date_fin TIMESTAMP NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(id) ON DELETE CASCADE,
    FOREIGN KEY (calcul_id) REFERENCES Catalog_Calculs(id) ON DELETE CASCADE
);
