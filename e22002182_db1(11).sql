-- phpMyAdmin SQL Dump
-- version 5.2.1deb1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : jeu. 05 déc. 2024 à 10:29
-- Version du serveur : 10.11.6-MariaDB-0+deb12u1-log
-- Version de PHP : 8.2.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `e22002182_db1`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`e22002182sql`@`%` PROCEDURE `act_concours` ()   BEGIN
    DECLARE ID INT; 
    DECLARE AUTEUR VARCHAR(100); 
    DECLARE NOM VARCHAR(100); 
    DECLARE DATE_DEBUT VARCHAR(100);
    DECLARE TEXTE_INTRO VARCHAR(100);  

    SET ID := (SELECT dernier_concours()); 
    SET AUTEUR := (SELECT cpt_login FROM t_concours_con WHERE con_id = ID);  
    SET NOM := (SELECT con_nom FROM t_concours_con WHERE con_id = ID);   
    SET DATE_DEBUT := (SELECT con_date_debut FROM t_concours_con WHERE con_id = ID);   
    SET TEXTE_INTRO := (SELECT con_nom FROM t_concours_con WHERE con_id = ID);

    INSERT INTO t_actualite_act (act_titre, act_description, act_date, con_id, act_etat) 
    VALUES (
        CONCAT_WS(' ', 'Nouveau concours :', NOM), 
        CONCAT_WS(' ', NOM, '(qui a débuté le', DATE_DEBUT, ') :', TEXTE_INTRO), 
        CURDATE(), 
        ID, 
        'A'
    );
END$$

CREATE DEFINER=`e22002182sql`@`%` PROCEDURE `act_concours_ajd` (IN `ID_concours` INT)   BEGIN
    DECLARE nom_orga VARCHAR(120);
    DECLARE nom_concours VARCHAR(200);
    DECLARE date_debut_concours DATETIME;

    SET nom_orga := id_organisateur_concours(ID_concours);
    
    SET nom_concours := (SELECT con_nom FROM t_concours_con WHERE con_id = ID_concours);
    SET date_debut_concours := (SELECT con_date_debut FROM t_concours_con WHERE con_id = ID_concours);
    
    INSERT INTO t_actualite_act (act_id, act_etat, act_description, act_titre, act_date, con_id) 
    VALUES (NULL, 'A', CONCAT('Nouveau ', nom_concours, ' - ', date_debut_concours), 
            CONCAT('Concours créé par ', nom_orga), NOW(), ID_concours);
END$$

CREATE DEFINER=`e22002182sql`@`%` PROCEDURE `supprimer_candidature` (IN `CODE_DOSSIER` CHAR(20), IN `CODE_CANDIDATURE` CHAR(8))   BEGIN
    DECLARE ID_CANDIDAT INT;

    SELECT can_id INTO ID_CANDIDAT
    FROM t_candidature_can
    WHERE can_dossier = CODE_DOSSIER AND can_code = CODE_CANDIDATURE;

    IF ID_CANDIDAT IS NOT NULL THEN
        DELETE FROM t_ressource_res WHERE can_id = ID_CANDIDAT;

        DELETE FROM t_candidature_can WHERE can_id = ID_CANDIDAT;
    END IF;
END$$

--
-- Fonctions
--
CREATE DEFINER=`e22002182sql`@`%` FUNCTION `age` (`dates` DATE) RETURNS INT(11)  BEGIN
    DECLARE age INT;
    SET age = YEAR(CURDATE()) - YEAR(dates);  
    IF (MONTH(CURDATE()) < MONTH(dates)) OR 
       (MONTH(CURDATE()) = MONTH(dates) AND DAY(CURDATE()) < DAY(dates)) THEN
        SET age = age - 1;
    END IF;
    
    RETURN age;
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `date_phase` (`date_debut` DATE, `jour_phase` INT) RETURNS DATE  BEGIN
		DECLARE DATE_PHASE DATE;

        SET DATE_PHASE := (SELECT DATE_ADD(date_debut, INTERVAL jour_phase DAY));
        RETURN DATE_PHASE;
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `dernier_concours` () RETURNS INT(11)  BEGIN
	DECLARE ID INT;
    SET ID := (SELECT MAX(con_id) FROM t_concours_con);
    RETURN ID;	
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `donner_listecategorie` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE CATEGORIE VARCHAR(120);
SET CATEGORIE := (SELECT GROUP_CONCAT(CONCAT(cat_nom, '') SEPARATOR '<br/>')
    AS categorie
from t_categorie_cat
JOIN t_choix_cho USING(cat_id)
JOIN t_concours_con USING(con_id)
where con_id = ID);
   
RETURN CATEGORIE;
  
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `donner_listediscipline` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE DISCIPLINE VARCHAR(120);
SET DISCIPLINE := (SELECT GROUP_CONCAT(CONCAT(jur_domaine_expertise, '') SEPARATOR '<br/>')
    AS discipline
from t_jury_jur
JOIN t_concours_con_has_t_jury_jur2 USING(jur_id)
JOIN t_concours_con USING(con_id)
where con_id = ID);
   
RETURN DISCIPLINE;
  
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `donner_listejury` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE JURY VARCHAR(120);
SET JURY := (SELECT GROUP_CONCAT(CONCAT(cpt_nom, ' ', cpt_prenom) SEPARATOR '\n')
    AS jury
FROM t_compte_cpt 
JOIN t_jury_jur USING (cpt_login) 
JOIN t_concours_con_has_t_jury_jur2 USING(jur_id)
JOIN t_concours_con USING(con_id)
            WHERE con_id = ID);
   
RETURN JURY;
  
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `etat_concours` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE DATE_DEBUT DATE;
    DECLARE PHASE_INSCRIPTION INT;
    DECLARE PHASE_PRESELECTION INT;
    DECLARE PHASE_FINALE INT;
    
    SET DATE_DEBUT = (SELECT con_date_debut FROM t_concours_con WHERE con_id = ID);
    SET PHASE_INSCRIPTION = (SELECT con_nb_jours_candidature FROM t_concours_con WHERE con_id = ID);
    SET PHASE_PRESELECTION = (SELECT con_nb_jours_preselection FROM t_concours_con WHERE con_id = ID);
    SET PHASE_FINALE = (SELECT con_nb_jours_finale FROM t_concours_con WHERE con_id = ID);

    IF (CURDATE() < DATE_DEBUT) THEN
        RETURN 'A venir';
    
    ELSEIF (CURDATE() <= ADDDATE(DATE_DEBUT, PHASE_INSCRIPTION)) THEN
        RETURN 'Inscriptions';
    
    ELSEIF (CURDATE() <= ADDDATE(ADDDATE(DATE_DEBUT, PHASE_INSCRIPTION), PHASE_PRESELECTION)) THEN
        RETURN 'Sélection';
    
    ELSEIF (CURDATE() <= ADDDATE(ADDDATE(ADDDATE(DATE_DEBUT, PHASE_INSCRIPTION), PHASE_PRESELECTION), PHASE_FINALE)) THEN
        RETURN 'Finale';
    
    ELSE 
        RETURN 'Terminé';
    END IF;
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `id_organisateur_concours` (`ID_concours` INT) RETURNS VARCHAR(120) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    RETURN (SELECT cpt_login from t_concours_con where con_id = ID_concours);	
END$$

CREATE DEFINER=`e22002182sql`@`%` FUNCTION `liste_jury` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE JURY VARCHAR(120);
SET JURY := (SELECT GROUP_CONCAT(CONCAT(cpt_nom, ' ', cpt_prenom) SEPARATOR ', ')
    AS jury
FROM t_compte_cpt 
JOIN t_jury_jur USING (cpt_login) 
JOIN t_concours_con_has_t_jury_jur2 USING(jur_id)
JOIN t_concours_con USING(con_id)
            WHERE con_id = ID);
   
RETURN JURY;
  
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `candidat`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `candidat` (
`can_nom` varchar(45)
,`can_prenom` varchar(45)
,`moyenne_note` decimal(7,4)
);

-- --------------------------------------------------------

--
-- Structure de la table `t_actualite_act`
--

CREATE TABLE `t_actualite_act` (
  `act_id` int(111) NOT NULL,
  `act_etat` char(1) NOT NULL,
  `act_description` varchar(1000) NOT NULL,
  `act_titre` varchar(80) NOT NULL,
  `act_date` datetime NOT NULL,
  `con_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_actualite_act`
--

INSERT INTO `t_actualite_act` (`act_id`, `act_etat`, `act_description`, `act_titre`, `act_date`, `con_id`) VALUES
(1, 'A', 'Lancement du concours de paysage', 'Lancement concours photo paysage', '2024-09-01 10:00:00', 1),
(2, 'A', 'Début des inscriptions pour le concours culinaire', 'Inscriptions concours culinaire', '2024-10-01 09:00:00', 2),
(3, 'D', 'Annonce du concours de peinture', 'Annonce concours peinture', '2024-11-01 11:00:00', 3),
(4, 'D', 'Ouverture des candidatures pour le concours de scuplture', 'Candidatures concours scuplture', '2024-12-01 08:00:00', 4),
(8, 'D', 'concours plume (qui a débuté le 2024-10-15 20:44:06 ) : concours plume', 'Nouveau concours : concours plume', '2024-10-15 00:00:00', 6),
(12, 'D', ' Attention, changement du nom\r\ndu concours Concours de paysageCccccconcours de paysage', 'Modification du nom du concnours ', '2024-10-16 00:00:00', 1),
(13, 'D', ' Attention, changement du nom\ndu concours Ccccccconcours de paysageCccconcours de paysage', 'Modification du nom du concnours ', '2024-10-16 14:33:43', 1),
(14, 'D', ' Attention, changement du nom\r\n    du concours Cccconcours de paysageCconcours de paysage', 'Modification du concnours ', '2024-10-16 14:40:06', 1),
(15, 'D', 'MODIFICATIONS DU CONCOURS => cf récapitulatif des concours\r\n!Cccconcours de paysageCconcours de paysage', 'Modification du concnours ', '2024-10-16 14:40:06', 1),
(16, 'D', 'Nouveau Cconcours de paysage - 2024-09-01 10:00:00', 'Concours créé par organisateur@Olympix.com', '2024-10-17 09:19:54', 1),
(19, 'D', 'Nouveau Concours culinaire - 2024-10-01 09:00:00', 'Concours créé par marcel.decheval@Olympix.com', '2024-10-23 18:27:46', 2),
(20, 'D', 'Nouveau Concours de peinture - 2024-11-01 11:00:00', 'Concours créé par marcel.decheval@Olympix.com', '2024-10-23 18:28:01', 3),
(21, 'D', 'Nouveau Concours culinaire - 2024-10-01 09:00:00', 'Concours créé par organisateur@Olympix.com', '2024-10-23 18:28:56', 2),
(22, 'D', 'Nouveau Concours de peinture - 2024-11-01 11:00:00', 'Concours créé par organisateur@Olympix.com', '2024-10-23 18:28:56', 3),
(23, 'D', 'Nouveau Concours culinaire - 2024-10-01 09:00:00', 'Concours créé par marcel.decheval@Olympix.com', '2024-10-23 18:29:17', 2),
(24, 'D', 'Nouveau Concours de peinture - 2024-11-01 11:00:00', 'Concours créé par marcel.decheval@Olympix.com', '2024-10-23 18:29:22', 3),
(25, 'D', ' Attention, changement du nom\r\n    du concours Cconcours de paysage2024 vmvm!!!', 'Modification du concnours ', '2024-10-24 08:53:41', 1),
(26, 'D', 'MODIFICATIONS DU CONCOURS => cf récapitulatif des concours\r\n!Cconcours de paysage2024 vmvm!!!', 'Modification du concnours ', '2024-10-24 08:53:41', 1),
(27, 'D', 'Nouveau 2024 vmvm!!! - 2024-09-01 10:00:00', 'Concours créé par organisateur@Olympix.com', '2024-10-24 08:53:41', 1),
(28, 'D', 'Nouveau Concours culinaire - 2024-10-01 09:00:00', 'Concours créé par organisateur@Olympix.com', '2024-10-24 08:56:19', 2),
(45, 'A', 'Nouveau 2024 vmvm!!! - 2024-12-05 10:00:00', 'Concours créé par organisateur@Olympix.com', '2024-12-05 07:08:48', 1),
(46, 'A', 'Nouveau 2024 vmvm!!! - 2024-12-06 10:00:00', 'Concours créé par organisateur@Olympix.com', '2024-12-05 07:09:17', 1),
(47, 'A', 'Nouveau concours plume - 2024-12-12 20:44:06', 'Concours créé par bernard.alice@Olympix.com', '2024-12-05 07:10:35', 6),
(48, 'A', ' Attention, changement du nom\r\n    du concours concours plumeConcoursd ', 'Modification du concnours ', '2024-12-05 07:13:09', 6),
(74, 'A', 'Nouveau Concours de lac - 2024-12-04 20:44:06', 'Concours créé par organisateur@Olympix.com', '2024-12-05 10:37:31', 6);

-- --------------------------------------------------------

--
-- Structure de la table `t_administrateur_adm`
--

CREATE TABLE `t_administrateur_adm` (
  `adm_id` int(111) NOT NULL,
  `adm_etat` char(1) NOT NULL,
  `cpt_login` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_administrateur_adm`
--

INSERT INTO `t_administrateur_adm` (`adm_id`, `adm_etat`, `cpt_login`) VALUES
(1, 'A', 'organisateur@Olympix.com'),
(2, 'A', 'martin.sophie@Olympix.com'),
(4, 'A', 'durand.pierre@Olympix.com'),
(5, 'A', 'bernard.alice@Olympix.com'),
(10, 'A', 'marcel.decheval@Olympix.com'),
(15, 'A', 'john.smith@Olympix.com');

-- --------------------------------------------------------

--
-- Structure de la table `t_candidature_can`
--

CREATE TABLE `t_candidature_can` (
  `can_id` int(111) NOT NULL,
  `can_code` char(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `can_dossier` char(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `can_prenom` varchar(45) NOT NULL,
  `can_nom` varchar(45) NOT NULL,
  `can_mail` varchar(60) NOT NULL,
  `can_retenue` char(1) NOT NULL,
  `can_date` date NOT NULL,
  `can_etat` char(1) NOT NULL,
  `cat_id` int(100) NOT NULL,
  `con_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_candidature_can`
--

INSERT INTO `t_candidature_can` (`can_id`, `can_code`, `can_dossier`, `can_prenom`, `can_nom`, `can_mail`, `can_retenue`, `can_date`, `can_etat`, `cat_id`, `con_id`) VALUES
(1, 'AQSwdze4', 'p5EFPm3fe5wXR28yS66c', 'organisateur', 'organisateur', 'organisateur@Olympix.com', 'R', '2024-10-05', 'A', 1, 3),
(2, 'X9y8Z7w6', 'FAUx5V58x2vgb99H2fGc', 'Sophie', 'Martin', 'sophie.martin@Olympix.com', 'R', '2024-10-27', 'A', 2, 2),
(3, 'K5l6M7n8', 'x6tBdUF6f477x3Wa5cVU', 'Clara', 'Lefevre', 'clara.lefevre@Olympix.com', 'I', '2024-10-16', 'A', 1, 5),
(4, 'P1q2R3s4', 'a9k5MAPgHN9p3cnj64S3', 'Pierre', 'Durand', 'pierre.durand@Olympix.com', 'I', '2024-10-31', 'A', 3, 5),
(5, 'H5j6K7l8', '4sHw8N4PSr38n3ZetB4q', 'Alice', 'Bernard', 'alice.bernard@Olympix.com', 'I', '2024-10-12', 'A', 2, 6),
(6, 'T7v8U9w0', 'dWrG36yBcxv75Ds97KG5', 'Sophie', 'Martin', 'sophie.martin@Olympix.com', 'I', '2024-10-16', 'A', 2, 3),
(8, 'M6n7O8p8', 'x5Ggk8V4F9U2Ut5kEa5d', 'Pierre', 'Durand', 'pierre.durand@Olympix.com', 'R', '2024-10-26', 'A', 2, 2),
(9, 'Q2x3AAz5', '6xqLRA8866s7XsdZ6vbW', 'Nicolas', 'Asticot', 'nicolas.asticot@Olympix.com', 'R', '2024-10-29', 'A', 1, 2),
(10, 'M6w4O8p9', 'x5Qgk8V4a932Uv5kEa5d', 'Pedro', 'Madaire', 'pedro.madaire@Olympix.com', 'R', '2024-10-15', 'A', 2, 3),
(11, 'L8p9Q2x3', 'j7HgL4p5Nd98s7BaCcX', 'Jean', 'Bon', 'jean.bon@Olympix.com', 'R', '2024-11-01', 'A', 1, 3),
(12, 'R7s9T3v1', 'k7V3Fz83Hd98x2a3BbFg', 'Anne', 'Onyme', 'anne.onyme@Olympix.com', 'R', '2024-11-03', 'A', 2, 3),
(13, 'N5k8O9p7', 'p5Xa6Fy32X7s9cNbHaFg', 'Guy', 'Tar', 'guy.tar@Olympix.com', 'R', '2024-11-05', 'A', 3, 3),
(15, 'H9w6M7k8', 'z9W4Fs8L39q2Hd8BbNcF', 'Léa', 'Titia', 'lea.titia@Olympix.com', 'R', '2024-11-09', 'A', 3, 3),
(20, 'P9o1Q3x7', 'k5X7V3LdHaFs8Nb4c3Bb', 'Hugo', 'Dinateur', 'hugo.dinateur@Olympix.com', 'I', '2024-11-15', 'A', 1, 6);

-- --------------------------------------------------------

--
-- Structure de la table `t_categorie_cat`
--

CREATE TABLE `t_categorie_cat` (
  `cat_id` int(111) NOT NULL,
  `cat_nom` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_categorie_cat`
--

INSERT INTO `t_categorie_cat` (`cat_id`, `cat_nom`) VALUES
(1, 'débutant'),
(2, 'intermédiaire'),
(3, 'expert');

-- --------------------------------------------------------

--
-- Structure de la table `t_choix_cho`
--

CREATE TABLE `t_choix_cho` (
  `con_id` int(111) NOT NULL,
  `cat_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_choix_cho`
--

INSERT INTO `t_choix_cho` (`con_id`, `cat_id`) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(3, 1),
(3, 2),
(3, 3),
(4, 1),
(5, 1),
(5, 2),
(5, 3),
(6, 1),
(6, 2),
(6, 3);

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_cpt`
--

CREATE TABLE `t_compte_cpt` (
  `cpt_login` varchar(120) NOT NULL,
  `cpt_mdp` char(128) NOT NULL,
  `cpt_nom` varchar(80) NOT NULL,
  `cpt_prenom` varchar(80) NOT NULL,
  `cpt_etat` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_compte_cpt`
--

INSERT INTO `t_compte_cpt` (`cpt_login`, `cpt_mdp`, `cpt_nom`, `cpt_prenom`, `cpt_etat`) VALUES
('amelie.dupont@Olympix.com', '4b99b914e3e19afce37d90259e8d24f1b09f5583a47f5119837a23f9c785b30e835f1dbe25912f6934f0b44ed9c9297b4b1ec0a99351e8e19a303fc3383ba20f', 'Dupont', 'Amélie', 'A'),
('bernard.alice@Olympix.com', '96bbac6d2d8d94add890121586b9bf711f70339bd00574d9b13804e663ae45bded641fe7bd6363652535a65d777ccc13dfe5ef9ddebdccc49097b2dd9bc1c07d', 'Bernarde', 'Alice', 'A'),
('durand.pierre@Olympix.com', 'dfc3db8c7e8fca038fbf8c282d10b4ec318b38f0e578be82fe18edde13b784a57bd82c885dfb130d3bb767263fc3d891ecc97fca2e23c86583fd59f460c98b44', 'Durand', 'Pierre', 'A'),
('john.smith@Olympix.com', '23fddf6842f14997d8577ccec137583b69c5372616da6013de9aa7cf96df42a8a3fa782a4ab98560eb7c09f962f7dce71457318528f8c0ad602a8eae3a937b73', 'Smith', 'John', 'A'),
('julie.riviere@Olympix.com', 'adc4c826ec3d32545a5bc22d1c3e0d8acdb204fbd9d3554ec52ffaf144b2814b2cd2fa52226ad813e3e9386f79e74a176409c1353e7db89be883e9088429f60e', 'Rivière', 'Julie', 'A'),
('jury29vm@Olympix.com', 'fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe', 'jury29vm@Olympix.com', 'jury29vm@Olympix.com', 'A'),
('lefevre.clara@Olympix.com', '1b86826867c99c60b3f7a14f7f947535c3f290381de5dc4feecd198ab5d03b7dc4ed37acebf0c7ac15d6b46f81ab7bf2b03964fc199673d25831ff471f047110', 'Lefevre', 'Clara', 'A'),
('lucas.martin@Olympix.com', 'e76bb905ec3a12f8c6db3b37a579c82605b91c5b20db18e5438b79271c6d5b45d3b84370dfb154f7bc72eddfaf2fdd993e7db4359e2d9b807e6ea2c0f1fa6c4e', 'Martin', 'Lucas', 'A'),
('marcel.decheval@Olympix.com', '6c89030400dbcd6561f8e03c8ccbeff4d8150988e635af53a581622da3223e37a64abb3f26a1cff7f0014c32e4ca615e76534fb53830e54c67603b892124c8d1', 'marcel', 'decheval', 'A'),
('marie.leroy@Olympix.com', '517b8f3d7c21f5d51c645a54c3167c0346d0e97e9fb0f12d468756f74b147f4f88b4eb8ad30e53e612f2c93cfb618b7891bda5cb6346e7eaa5739243b68287b2', 'Leroy', 'Marie', 'A'),
('martin.sophie@Olympix.com', '43c05007803c24e3bf06524a0312a47c497c2ad4244e909c39d8c7b809f0128e6159c1e71fbf2c6469380700b091f30323929a6800d0b8ea1b1020156eb6035f', 'Martin', 'Sophie', 'A'),
('nicolas.asticot@Olympix.com', '06f3619044ef2b5e8e9a23b4aae20a4999ce19f0b9f4d532fc8fe47f9c4bb8019ce7100931843fa9d10872341fad2086bf3889d331575bcd132cccec77d7590b', 'Asticot', 'Nicolas', 'A'),
('organisateur@Olympix.com', 'fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe', 'organisateur', 'organisateur', 'A'),
('thomas.giraud@Olympix.com', '84bd726c39c4d79b3cf35bc1b229062a4cbdf3b891234d34abf8725dca7451f8c92a9f90dffbaf8b2ab1124f123cab7f265c5e5c548ba66f4e6274be61c2d77e', 'Giraud', 'Thomas', 'A');

--
-- Déclencheurs `t_compte_cpt`
--
DELIMITER $$
CREATE TRIGGER `suppression_compte_organisateur` BEFORE DELETE ON `t_compte_cpt` FOR EACH ROW BEGIN  
    DECLARE organisateur VARCHAR(120);
    DECLARE id_concours INT;

  
    SET organisateur := (OLD.cpt_login);


    UPDATE t_concours_con 
    SET cpt_login = 'organisateur@Olympix.com' 
    WHERE cpt_login = organisateur;


    DELETE FROM t_actualite_act 
    WHERE con_id IN (SELECT con_id FROM t_concours_con WHERE cpt_login = organisateur);

  
    DELETE FROM t_administrateur_adm 
    WHERE cpt_login = organisateur;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_concours_con`
--

CREATE TABLE `t_concours_con` (
  `con_id` int(111) NOT NULL,
  `con_nom` varchar(80) NOT NULL,
  `con_date_debut` datetime NOT NULL,
  `con_nb_jours_candidature` int(111) NOT NULL,
  `con_nb_jours_preselection` int(111) NOT NULL,
  `con_discipline` varchar(80) NOT NULL,
  `con_duree_concours` int(111) NOT NULL,
  `con_nb_jours_finale` int(111) NOT NULL,
  `con_description` varchar(200) NOT NULL,
  `cpt_login` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_concours_con`
--

INSERT INTO `t_concours_con` (`con_id`, `con_nom`, `con_date_debut`, `con_nb_jours_candidature`, `con_nb_jours_preselection`, `con_discipline`, `con_duree_concours`, `con_nb_jours_finale`, `con_description`, `cpt_login`) VALUES
(1, 'Concours  d\'arbre', '2024-12-06 10:00:00', 9, 3, 'Nature', 120, 5, 'Capturez la beauté de la nature à travers l\'objectif.', 'organisateur@Olympix.com'),
(2, 'Concours culinaire', '2024-11-19 09:00:00', 2, 4, 'culinaire', 90, 5, 'Exprimez votre talent gastronomique avec des créations uniques.', 'john.smith@Olympix.com'),
(3, 'Concours de peinture', '2024-11-24 11:00:00', 3, 5, 'peinture', 100, 5, 'Capturez l\'âme des peintures à travers votre objectif.', 'bernard.alice@Olympix.com'),
(4, 'Concours de scuplture', '2024-12-12 08:00:00', 4, 6, 'scuplture', 60, 5, 'Mettez en lumière la finesse des sculptures avec votre talent de photographe.', 'durand.pierre@Olympix.com'),
(5, 'Concours animalier', '2024-11-25 10:00:00', 5, 7, 'animalier', 150, 5, 'Saisissez la beauté et le dynamisme de la faune sauvage.', 'marcel.decheval@Olympix.com'),
(6, 'Concours de lac', '2024-12-04 20:44:06', 6, 8, 'lac', 1, 5, 'Reflétez la sérénité et l\'immensité des paysages lacustres.', 'organisateur@Olympix.com');

--
-- Déclencheurs `t_concours_con`
--
DELIMITER $$
CREATE TRIGGER `ajout_act` AFTER INSERT ON `t_concours_con` FOR EACH ROW BEGIN
    CALL act_concours();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `changement_nom_concours` AFTER UPDATE ON `t_concours_con` FOR EACH ROW BEGIN   
    IF(OLD.con_nom != NEW.con_nom AND(OLD.con_id = NEW.con_id 
    AND
    OLD.con_date_debut = NEW.con_date_debut
    AND 
    OLD.con_nb_jours_candidature = NEW.con_nb_jours_candidature 
    AND 
    OLD.con_nb_jours_preselection = NEW.con_nb_jours_preselection 
    AND
    OLD.con_discipline = NEW.con_discipline 
    AND
    OLD.con_duree_concours = NEW.con_duree_concours 
    AND
    OLD.con_nb_jours_finale = NEW.con_nb_jours_finale 
    AND 
    OLD.con_description = NEW.con_description 
    AND 
    OLD.cpt_login = NEW.cpt_login))
    THEN
    INSERT INTO t_actualite_act (act_id, act_etat, act_description, act_titre, act_date, con_id) 
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,' Attention, changement du nom\r\n    du concours ', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
    END IF;
    IF(OLD.con_nom != NEW.con_nom AND((OLD.con_id = NEW.con_id OR OLD.con_id != NEW.con_id) 
    AND
    (OLD.con_date_debut = NEW.con_date_debut OR OLD.con_date_debut != NEW.con_date_debut)
    AND 
    (OLD.con_nb_jours_candidature = NEW.con_nb_jours_candidature OR OLD.con_nb_jours_candidature != NEW.con_nb_jours_candidature) 
    AND 
    (OLD.con_nb_jours_preselection = NEW.con_nb_jours_preselection  OR OLD.con_nb_jours_preselection != NEW.con_nb_jours_preselection)
    AND
    (OLD.con_discipline = NEW.con_discipline OR OLD.con_discipline != NEW.con_discipline) 
    AND
    (OLD.con_duree_concours = NEW.con_duree_concours OR OLD.con_duree_concours != NEW.con_duree_concours) 
    AND
    (OLD.con_nb_jours_finale = NEW.con_nb_jours_finale OR OLD.con_nb_jours_finale != NEW.con_nb_jours_finale) 
    AND 
    (OLD.con_description = NEW.con_description OR OLD.con_description != NEW.con_description) 
    AND 
    (OLD.cpt_login = NEW.cpt_login OR OLD.cpt_login != NEW.cpt_login)))
    THEN
    INSERT INTO t_actualite_act (act_id, act_etat, act_description, act_titre, act_date, con_id) 
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,'MODIFICATIONS DU CONCOURS => cf récapitulatif des concours\r\n!', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `new_act_concours` AFTER UPDATE ON `t_concours_con` FOR EACH ROW BEGIN   
    CALL act_concours_ajd(NEW.con_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_concours_con_has_t_jury_jur2`
--

CREATE TABLE `t_concours_con_has_t_jury_jur2` (
  `con_id` int(111) NOT NULL,
  `jur_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_concours_con_has_t_jury_jur2`
--

INSERT INTO `t_concours_con_has_t_jury_jur2` (`con_id`, `jur_id`) VALUES
(1, 1),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(3, 1),
(3, 2),
(3, 3),
(3, 14),
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(5, 1),
(5, 2),
(5, 5),
(6, 1),
(6, 2),
(6, 5);

-- --------------------------------------------------------

--
-- Structure de la table `t_fil_discussion_fil`
--

CREATE TABLE `t_fil_discussion_fil` (
  `fil_id` int(111) NOT NULL,
  `con_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_fil_discussion_fil`
--

INSERT INTO `t_fil_discussion_fil` (`fil_id`, `con_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- --------------------------------------------------------

--
-- Structure de la table `t_jury_jur`
--

CREATE TABLE `t_jury_jur` (
  `jur_id` int(111) NOT NULL,
  `jur_biographie` varchar(2000) NOT NULL,
  `jur_url` varchar(300) NOT NULL,
  `jur_domaine_expertise` varchar(80) NOT NULL,
  `cpt_login` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_jury_jur`
--

INSERT INTO `t_jury_jur` (`jur_id`, `jur_biographie`, `jur_url`, `jur_domaine_expertise`, `cpt_login`) VALUES
(1, 'Biographie Jury Photographie', 'http://jury-photo.com', 'Nature', 'thomas.giraud@Olympix.com'),
(2, 'Biographie Jury Musique', 'http://jury-musique.com', 'Ocean', 'lucas.martin@Olympix.com'),
(3, 'Biographie Jury Peinture', 'http://jury-peinture.com', 'peintures', 'lefevre.clara@Olympix.com'),
(4, 'Biographie Jury Danse', 'http://jury-danse.com', 'Nourriture', 'nicolas.asticot@Olympix.com'),
(5, 'Biographie Jury Littérature', 'http://jury-litterature.com', 'Montagne', 'amelie.dupont@Olympix.com'),
(14, '', '', '', 'jury29vm@Olympix.com');

-- --------------------------------------------------------

--
-- Structure de la table `t_message_mes`
--

CREATE TABLE `t_message_mes` (
  `mes_id` int(111) NOT NULL,
  `mes_texte` varchar(600) NOT NULL,
  `jur_id` int(111) NOT NULL,
  `fil_id` int(111) NOT NULL,
  `mes_etat` char(1) NOT NULL,
  `mes_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_message_mes`
--

INSERT INTO `t_message_mes` (`mes_id`, `mes_texte`, `jur_id`, `fil_id`, `mes_etat`, `mes_date`) VALUES
(1, 'Message sur le concours de photographie', 1, 1, 'A', '2024-09-01 11:00:00'),
(2, 'Message sur le concours de musique', 2, 2, 'A', '2024-10-01 10:00:00'),
(3, 'Message sur le concours de peinture', 3, 3, 'A', '2024-11-01 12:00:00'),
(4, 'Message sur le concours de danse', 4, 4, 'A', '2024-12-01 09:00:00'),
(5, 'Message sur le concours d\'écriture', 5, 5, 'A', '2024-08-01 11:00:00');

-- --------------------------------------------------------

--
-- Structure de la table `t_note_not`
--

CREATE TABLE `t_note_not` (
  `can_id` int(111) NOT NULL,
  `jur_id` int(111) NOT NULL,
  `not_note` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_note_not`
--

INSERT INTO `t_note_not` (`can_id`, `jur_id`, `not_note`) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(8, 5, 5),
(10, 5, 4),
(12, 4, 5);

-- --------------------------------------------------------

--
-- Structure de la table `t_ressource_res`
--

CREATE TABLE `t_ressource_res` (
  `res_id` int(111) NOT NULL,
  `res_nom` varchar(80) NOT NULL,
  `res_description` varchar(500) NOT NULL,
  `res_chemin` varchar(200) NOT NULL,
  `res_type` tinyint(5) NOT NULL,
  `can_id` int(111) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_ressource_res`
--

INSERT INTO `t_ressource_res` (`res_id`, `res_nom`, `res_description`, `res_chemin`, `res_type`, `can_id`) VALUES
(1, 'tableau de fleurs', 'Image soumise pour le concours de photographie', 'tableau2.jpeg', 1, 8),
(4, 'Fichier scuplture', 'Scuplture pour le concours de photo scuplture', 'sculpture.jpg', 1, 10),
(16, 'tableau simple', 'tableau de peinture', 'tableau.jpg', 1, 15);

-- --------------------------------------------------------

--
-- Structure de la vue `candidat`
--
DROP TABLE IF EXISTS `candidat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`e22002182sql`@`%` SQL SECURITY DEFINER VIEW `candidat`  AS SELECT `t_candidature_can`.`can_nom` AS `can_nom`, `t_candidature_can`.`can_prenom` AS `can_prenom`, avg(`t_note_not`.`not_note`) AS `moyenne_note` FROM (`t_candidature_can` join `t_note_not` on(`t_candidature_can`.`can_id` = `t_note_not`.`can_id`)) GROUP BY `t_candidature_can`.`can_nom`, `t_candidature_can`.`can_prenom` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  ADD PRIMARY KEY (`act_id`),
  ADD KEY `fk_t_actualite_act_t_concours_con1_idx` (`con_id`);

--
-- Index pour la table `t_administrateur_adm`
--
ALTER TABLE `t_administrateur_adm`
  ADD PRIMARY KEY (`adm_id`),
  ADD UNIQUE KEY `cpt_login` (`cpt_login`),
  ADD KEY `fk_t_administrateur_adm_t_compte_cpt1_idx` (`cpt_login`);

--
-- Index pour la table `t_candidature_can`
--
ALTER TABLE `t_candidature_can`
  ADD PRIMARY KEY (`can_id`),
  ADD KEY `fk_t_candidature_can_t_concours_con1_idx` (`con_id`),
  ADD KEY `fk_t_candidature_can_t_categorie_cat1_idx` (`cat_id`) USING BTREE;

--
-- Index pour la table `t_categorie_cat`
--
ALTER TABLE `t_categorie_cat`
  ADD PRIMARY KEY (`cat_id`);

--
-- Index pour la table `t_choix_cho`
--
ALTER TABLE `t_choix_cho`
  ADD PRIMARY KEY (`con_id`,`cat_id`),
  ADD KEY `fk_t_concours_con_has_t_categorie_cat_t_categorie_cat1_idx` (`cat_id`),
  ADD KEY `fk_t_concours_con_has_t_categorie_cat_t_concours_con1_idx` (`con_id`);

--
-- Index pour la table `t_compte_cpt`
--
ALTER TABLE `t_compte_cpt`
  ADD PRIMARY KEY (`cpt_login`),
  ADD UNIQUE KEY `cpt_login` (`cpt_login`);

--
-- Index pour la table `t_concours_con`
--
ALTER TABLE `t_concours_con`
  ADD PRIMARY KEY (`con_id`),
  ADD KEY `fk_t_concours_con_t_compte_cpt1_idx` (`cpt_login`);

--
-- Index pour la table `t_concours_con_has_t_jury_jur2`
--
ALTER TABLE `t_concours_con_has_t_jury_jur2`
  ADD PRIMARY KEY (`con_id`,`jur_id`),
  ADD KEY `fk_t_concours_con_has_t_jury_jur2_t_jury_jur1_idx` (`jur_id`),
  ADD KEY `fk_t_concours_con_has_t_jury_jur2_t_concours_con1_idx` (`con_id`);

--
-- Index pour la table `t_fil_discussion_fil`
--
ALTER TABLE `t_fil_discussion_fil`
  ADD PRIMARY KEY (`fil_id`),
  ADD KEY `fk_t_fil_discussion_fil_t_concours_con1_idx` (`con_id`);

--
-- Index pour la table `t_jury_jur`
--
ALTER TABLE `t_jury_jur`
  ADD PRIMARY KEY (`jur_id`),
  ADD UNIQUE KEY `cpt_login` (`cpt_login`),
  ADD KEY `fk_t_jury_jur_t_compte_cpt1_idx` (`cpt_login`);

--
-- Index pour la table `t_message_mes`
--
ALTER TABLE `t_message_mes`
  ADD PRIMARY KEY (`mes_id`),
  ADD KEY `fk_t_message_mes_t_jury_jur1_idx` (`jur_id`),
  ADD KEY `fk_t_message_mes_t_fil_discussion_fil1_idx` (`fil_id`);

--
-- Index pour la table `t_note_not`
--
ALTER TABLE `t_note_not`
  ADD PRIMARY KEY (`can_id`,`jur_id`),
  ADD KEY `fk_t_candidature_can_has_t_jury_jur_t_jury_jur1_idx` (`jur_id`),
  ADD KEY `fk_t_candidature_can_has_t_jury_jur_t_candidature_can1_idx` (`can_id`);

--
-- Index pour la table `t_ressource_res`
--
ALTER TABLE `t_ressource_res`
  ADD PRIMARY KEY (`res_id`),
  ADD KEY `fk_t_ressource_res_t_candidature_can_idx` (`can_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  MODIFY `act_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT pour la table `t_administrateur_adm`
--
ALTER TABLE `t_administrateur_adm`
  MODIFY `adm_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT pour la table `t_candidature_can`
--
ALTER TABLE `t_candidature_can`
  MODIFY `can_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `t_categorie_cat`
--
ALTER TABLE `t_categorie_cat`
  MODIFY `cat_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `t_concours_con`
--
ALTER TABLE `t_concours_con`
  MODIFY `con_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `t_jury_jur`
--
ALTER TABLE `t_jury_jur`
  MODIFY `jur_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `t_message_mes`
--
ALTER TABLE `t_message_mes`
  MODIFY `mes_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `t_ressource_res`
--
ALTER TABLE `t_ressource_res`
  MODIFY `res_id` int(111) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  ADD CONSTRAINT `fk_t_actualite_act_t_concours_con1` FOREIGN KEY (`con_id`) REFERENCES `t_concours_con` (`con_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_administrateur_adm`
--
ALTER TABLE `t_administrateur_adm`
  ADD CONSTRAINT `fk_t_administrateur_adm_t_compte_cpt1` FOREIGN KEY (`cpt_login`) REFERENCES `t_compte_cpt` (`cpt_login`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_candidature_can`
--
ALTER TABLE `t_candidature_can`
  ADD CONSTRAINT `fk_t_candidature_can_t_categorie_cat1` FOREIGN KEY (`cat_id`) REFERENCES `t_categorie_cat` (`cat_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_candidature_can_t_concours_con1` FOREIGN KEY (`con_id`) REFERENCES `t_concours_con` (`con_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_choix_cho`
--
ALTER TABLE `t_choix_cho`
  ADD CONSTRAINT `fk_t_concours_con_has_t_categorie_cat_t_categorie_cat1` FOREIGN KEY (`cat_id`) REFERENCES `t_categorie_cat` (`cat_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_concours_con_has_t_categorie_cat_t_concours_con1` FOREIGN KEY (`con_id`) REFERENCES `t_concours_con` (`con_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_concours_con`
--
ALTER TABLE `t_concours_con`
  ADD CONSTRAINT `fk_t_concours_con_t_compte_cpt1` FOREIGN KEY (`cpt_login`) REFERENCES `t_compte_cpt` (`cpt_login`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_concours_con_has_t_jury_jur2`
--
ALTER TABLE `t_concours_con_has_t_jury_jur2`
  ADD CONSTRAINT `fk_t_concours_con_has_t_jury_jur2_t_concours_con1` FOREIGN KEY (`con_id`) REFERENCES `t_concours_con` (`con_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_concours_con_has_t_jury_jur2_t_jury_jur1` FOREIGN KEY (`jur_id`) REFERENCES `t_jury_jur` (`jur_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_fil_discussion_fil`
--
ALTER TABLE `t_fil_discussion_fil`
  ADD CONSTRAINT `fk_t_fil_discussion_fil_t_concours_con1` FOREIGN KEY (`con_id`) REFERENCES `t_concours_con` (`con_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_jury_jur`
--
ALTER TABLE `t_jury_jur`
  ADD CONSTRAINT `fk_t_jury_jur_t_compte_cpt1` FOREIGN KEY (`cpt_login`) REFERENCES `t_compte_cpt` (`cpt_login`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_message_mes`
--
ALTER TABLE `t_message_mes`
  ADD CONSTRAINT `fk_t_message_mes_t_fil_discussion_fil1` FOREIGN KEY (`fil_id`) REFERENCES `t_fil_discussion_fil` (`fil_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_message_mes_t_jury_jur1` FOREIGN KEY (`jur_id`) REFERENCES `t_jury_jur` (`jur_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_note_not`
--
ALTER TABLE `t_note_not`
  ADD CONSTRAINT `fk_t_candidature_can_has_t_jury_jur_t_candidature_can1` FOREIGN KEY (`can_id`) REFERENCES `t_candidature_can` (`can_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_candidature_can_has_t_jury_jur_t_jury_jur1` FOREIGN KEY (`jur_id`) REFERENCES `t_jury_jur` (`jur_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_ressource_res`
--
ALTER TABLE `t_ressource_res`
  ADD CONSTRAINT `fk_t_ressource_res_t_candidature_can` FOREIGN KEY (`can_id`) REFERENCES `t_candidature_can` (`can_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
