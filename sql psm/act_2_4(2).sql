--View candidat nom,prenom, moyenne des notes du jury
drop view candidat;
CREATE VIEW candidat AS
SELECT can_nom,
    can_prenom,
    AVG(not_note) AS moyenne_note
FROM t_candidature_can
    JOIN t_note_not ON t_candidature_can.can_id = t_note_not.can_id -- Jonction via un identifiant commun
GROUP BY can_nom,
    can_prenom;
SELECT *
FROM candidat;


--Activité 1
--1 Écrivez une fonction qui retourne l ’ identifiant du dernier concours ajouté dans la table de gestion des concours.➔ Testez cette fonction.
DROP FUNCTION IF EXISTS dernier_concours;

DELIMITER //
CREATE FUNCTION dernier_concours( ) RETURNS INT 
BEGIN
	DECLARE ID INT;
    SET ID := (SELECT MAX(con_id) FROM t_concours_con);
    RETURN ID;	
END;
//
DELIMITER ;

SELECT dernier_concours();

--2 Écrivez alors une procédure qui insère une actualité à la date d ’ aujourd ’ hui à partir du dernier 
--concours créé dans la table de gestion des concours en indiquant comme texte de l ’ actualité le nom du concours,
--sa date de début et le petit texte introductif.L ’ auteur de l ’ actualité sera l ’ organisateur responsable du concours.➔ Testez cette procédure

DROP PROCEDURE IF EXISTS act_concours;

DELIMITER //
CREATE PROCEDURE act_concours() 
BEGIN
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
END;
//
DELIMITER ;

CALL act_concours();
-- --q3 Puis,
-- en réutilisant ce qui a été fait précédemment,
-- créez un déclencheur (trigger) ajoutant une actualité dès la création d ’ un nouveau concours.➔ Activez ce trigger.

DROP TRIGGER IF EXISTS ajout_act;

DELIMITER //
CREATE TRIGGER ajout_act
AFTER INSERT ON t_concours_con
FOR EACH ROW
BEGIN
    CALL act_concours();
END;
//
DELIMITER ;

INSERT INTO `t_concours_con` (
        `con_id`,
        `con_nom`,
        `con_date_debut`,
        `con_nb_jours_candidature`,
        `con_nb_jours_preselection`,
        `con_discipline`,
        `con_duree_concours`,
        `con_nb_jours_finale`,
        `con_description`,
        `cpt_login`
    )
VALUES
VALUES (
        NULL,
        'concours plume',
        '2024-10-15 20:44:06.000000',
        6,
        7,
        'test',
        3,
        8,
        'test',
        'organisateur@Olympix'
    );
-- activité 2--

DROP FUNCTION IF EXISTS date_phase;

DELIMITER //
CREATE FUNCTION date_phase(date_debut DATE, jour_phase INT) RETURNS DATE 
BEGIN
		DECLARE DATE_PHASE DATE;

        SET DATE_PHASE := (SELECT DATE_ADD(date_debut, INTERVAL jour_phase DAY));
        RETURN DATE_PHASE;
END;
//
DELIMITER ;

SELECT con_date_debut INTO @date FROM t_concours_con WHERE con_id=1;
SELECT con_nb_jours_finale INTO @phase FROM t_concours_con WHERE con_id=1;
SELECT @date, @phase;
SELECT date_phase(@date,@phase);

DROP FUNCTION IF EXISTS etat_concours;

DELIMITER //
CREATE FUNCTION etat_concours(ID INT) RETURNS TEXT 
BEGIN
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
END;
//
DELIMITER ;

SELECT etat_concours(3);

--mdp hashage
DROP TRIGGER IF EXISTS hash_salt_mdp;
DELIMITER // CREATE TRIGGER hash_salt_mdp BEFORE
INSERT ON t_compte_cpt FOR EACH ROW BEGIN
SET NEW.cpt_mdp = SHA2(CONCAT(NEW.cpt_mdp, 'monsel524'), 512);
END;
// DELIMITER ;
INSERT INTO `t_compte_cpt` (
        `cpt_login`,
        `cpt_mdp`,
        `cpt_nom`,
        `cpt_prenom`,
        `cpt_etat`
    )
VALUES ('hash@olympix', 'hash', 'hash', 'hash', 'A');

--ACTIVITE 3 : manipulations de OLD et NEW

-- → Trigger 1
-- Créez un trigger qui suite à la modification d’une ou plusieurs donnée(s) d’un concours,
-- ajoute une nouvelle actualité :
-- - si c’est uniquement le nom du concours qui a changé, le texte de l’actualité contiendra
-- l’ancien nom du concours concerné suivi de la mention « Attention, changement du nom
-- du concours » suivi du nouveau nom du concours,
-- - pour toutes les autres modifications, on lira, dans le texte de l’actualité, le titre du
-- concours suivi de « MODIFICATIONS DU CONCOURS => cf récapitulatif des concours
-- ! ».
DROP TRIGGER IF EXISTS changement_nom_concours;
DELIMITER // CREATE TRIGGER changement_nom_concours
AFTER UPDATE ON t_concours_con
FOR EACH ROW 
BEGIN   
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
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,' Attention, changement du nom
    du concours ', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
    END IF;
    IF(OLD.con_nom != NEW.con_nom AND((OLD.con_id = NEW.con_id OR OLD.con_id != NEW.con_id) 
    AND
    (OLD.con_date_debut = NEW.con_date_de IF(OLD.con_nom != NEW.con_nom AND(OLD.con_id = NEW.con_id 
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
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,' Attention, changement du nom
    du concours ', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
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
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,'MODIFICATIONS DU CONCOURS => cf récapitulatif des concours
!', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
END IF;but OR OLD.con_date_debut != NEW.con_date_debut)
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
    VALUES(NULL, 'A', CONCAT_WS(OLD.con_nom,'MODIFICATIONS DU CONCOURS => cf récapitulatif des concours
!', NEW.con_nom), 'Modification du concnours ', NOW(), NEW.con_id);
END IF;

END;
// DELIMITER ;

-- → Trigger 2
-- Créez un trigger qui, suite à la suppression du compte d’un organisateur, supprime les
-- actualités qu’il a ajoutées et modifie l’auteur de ses concours en les associant au compte
-- de l’organisateur principal.

DROP TRIGGER IF EXISTS suppression_compte_organisateur;
DELIMITER //

CREATE TRIGGER suppression_compte_organisateur
BEFORE DELETE ON t_compte_cpt
FOR EACH ROW 
BEGIN  
    DECLARE organisateur VARCHAR(120);
    DECLARE id_concours INT;


    SET organisateur := OLD.cpt_login;

    UPDATE t_concours_con 
    SET cpt_login = 'organisateur@Olympix' 
    WHERE cpt_login = organisateur;

    DELETE FROM t_actualite_act 
    WHERE con_id IN (SELECT con_id FROM t_concours_con WHERE cpt_login = organisateur);

    DELETE FROM t_administrateur_adm 
    WHERE cpt_login = organisateur;
END;
//
DELIMITER ;
DELETE FROM t_compte_cpt WHERE `t_compte_cpt`.`cpt_login` = 'marcel.decheval@Olympix';

-- ACTIVITE 4 : BONUS – Variante de l’ACTIVITE 2
-- 1) Écrivez une fonction qui retourne l'identifiant de l'organisateur d'un concours dont
-- on passe l'identifiant en paramètre.
-- ➔ Testez cette fonction.


DROP FUNCTION IF EXISTS id_organisateur_concours;

DELIMITER //
CREATE FUNCTION id_organisateur_concours(ID_concours INT) RETURNS VARCHAR(120) 
BEGIN
    RETURN (SELECT cpt_login from t_concours_con where con_id = ID_concours);	
END;
//
DELIMITER ;

SELECT id_organisateur_concours(1);
SELECT id_organisateur_concours(2);
SELECT id_organisateur_concours(3);

-- 2) Écrivez alors une procédure qui appelle la fonction créée précédemment et
-- insère une actualité à la date d’aujourd’hui à partir du concours dont on passe
-- l’identifiant en paramètre en indiquant comme texte de l’actualité le nom du
-- concours, sa date de début et le petit texte introductif. L’auteur de l’actualité sera
-- l’organisateur responsable du concours.
-- ➔ Testez cette procédure.
DROP PROCEDURE IF EXISTS act_concours_ajd;

DELIMITER //
CREATE PROCEDURE act_concours_ajd(IN ID_concours INT) 
BEGIN
    DECLARE nom_orga VARCHAR(120);
    DECLARE nom_concours VARCHAR(200);
    DECLARE date_debut_concours DATETIME;

    SET nom_orga := id_organisateur_concours(ID_concours);
    
    SET nom_concours := (SELECT con_nom FROM t_concours_con WHERE con_id = ID_concours);
    SET date_debut_concours := (SELECT con_date_debut FROM t_concours_con WHERE con_id = ID_concours);
    
    INSERT INTO t_actualite_act (act_id, act_etat, act_description, act_titre, act_date, con_id) 
    VALUES (NULL, 'A', CONCAT('Nouveau ', nom_concours, ' - ', date_debut_concours), 
            CONCAT('Concours créé par ', nom_orga), NOW(), ID_concours);
END;
//
DELIMITER ;

CALL act_concours_ajd(1);

-- 3) Puis, en réutilisant ce qui a été fait précédemment, créez un déclencheur
-- (trigger) ajoutant une actualité dès la création d’un nouveau concours.
-- ➔ Activez ce trigger.

DROP TRIGGER IF EXISTS new_act_concours;
DELIMITER // CREATE TRIGGER new_act_concours
AFTER UPDATE ON t_concours_con
FOR EACH ROW 
BEGIN   
    CALL act_concours_ajd(NEW.con_id);
END;
// DELIMITER ;
