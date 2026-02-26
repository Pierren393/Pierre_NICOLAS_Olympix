
-- ACTIVITE 2--

SELECT MAX(pfl_id) INTO @identifiant2 FROM t_profil_pfl;

SET @identifiant := (SELECT MAX(pfl_id) FROM t_profil_pfl);


SET @identifiant := (SELECT MAX(pfl_id) FROM t_profil_pfl);
SELECT @identifiant;
INSERT INTO t_compte_cpt VALUES (@identifiant, 'pseudo', 'mdp');

SET @annee := (SELECT YEAR(pfl_date) FROM t_profil_pfl ORDER BY pfl_date ASC LIMIT 1);
SELECT @annee;
              

CREATE VIEW PROFIL
AS SELECT pfl_nom, pfl_prenom
FROM t_profil_pfl;
SELECT * FROM PROFIL;

UPDATE t_profil_pfl SET pfl_prenom = 'Valentina' WHERE pfl_prenom = 'Valentin';

DELIMITER //
CREATE FUNCTION hello_world(choix INT) RETURNS TEXT BEGIN
	IF choix=1 THEN
		RETURN 'Hello World !';
	ELSE
		RETURN 'Bonjour tout le monde !';
	END IF; 
END;
//
DELIMITER ;

SELECT hello_world(3);
SELECT hello_world(1);

-- activité 3-- 
DELIMITER //

CREATE FUNCTION age(date DATE) RETURNS INT 
BEGIN
	IF (MONTH(CURDATE()) > MONTH(date)) or ((MONTH(CURDATE()) = MONTH(date)) and (DAY(CUDATE()) >= DAY(date))) THEN
		RETURN YEAR(CURDATE()) - YEAR(date);
	ELSE 
		RETURN YEAR(CURDATE()) - YEAR(date)-1;
	END IF;
		
END;
//
DELIMITER ;

-- td2 --

-- correction :  ACTIVITE 3 --

DROP FUNCTION IF EXISTS donner_age2;

DELIMITER //
CREATE FUNCTION donner_age2(date DATE) RETURNS INT 
BEGIN
	DECLARE AGE INT DEFAULT 0;
	SET AGE := YEAR(CURDATE())-YEAR(date);
	IF (MONTH(date)>MONTH(CURDATE()) OR (MONTH(date)=MONTH(CURDATE()) AND DAY(date)>DAY(CURDATE())))
		THEN SET AGE := (AGE-1);
	END iF;
	RETURN AGE;		
END;
//
DELIMITER ;

SELECT pfl_nom, pfl_prenom, donner_age2(pfl_date_naissance) as AGE FROM t_profil_pfl;

SELECT TIMESTAMPDIFF(YEAR, '1971-05-06', CURDATE()) AS age;


DELIMITER //
CREATE FUNCTION donner_age3(date DATE) RETURNS INT 
BEGIN
	DECLARE AGE INT DEFAULT 0;
	SET AGE := (SELECT TIMESTAMPDIFF(YEAR, date, CURDATE()));
	RETURN AGE;		
END;
//
DELIMITER ;

--ACTIVITE 4--
--1--

DROP PROCEDURE IF EXISTS age;

DELIMITER //
CREATE PROCEDURE age(IN ID INT, OUT AGE INT) 
BEGIN
	DECLARE DATE_NAISSANCE DATE;
    SET DATE_NAISSANCE := (SELECT pfl_date_naissance FROM t_profil_pfl WHERE pfl_id = ID);
	SET AGE := (SELECT TIMESTAMPDIFF(YEAR, DATE_NAISSANCE, CURDATE()));
END;
//
DELIMITER ;

CALL age(1,@age);
SELECT @age;

--2--
DROP PROCEDURE IF EXISTS mineur;

DELIMITER //
CREATE PROCEDURE mineur(IN ID INT, OUT AGE INT, OUT MESSAGE VARCHAR(10)) 
BEGIN
	DECLARE DATE_NAISSANCE DATE;
    SET DATE_NAISSANCE := (SELECT pfl_date_naissance FROM t_profil_pfl WHERE pfl_id = ID);
    SET AGE := (SELECT donner_age3(DATE_NAISSANCE));
                
    IF (AGE < 18) THEN
                SET MESSAGE := "mineur";
    ELSE
                SET MESSAGE := "majeur";
    END IF;
                 
END;
//
DELIMITER ;

CALL mineur(1,@age,@message);
SELECT @age,@message;

--3--
DROP VIEW IF EXISTS PROFIL2;

CREATE VIEW PROFIL2
AS SELECT pfl_nom, pfl_prenom, donner_age3(pfl_date_naissance) AS age
FROM t_profil_pfl;

SELECT * FROM PROFIL2;

DROP PROCEDURE IF EXISTS age_moyen;

DELIMITER //
CREATE PROCEDURE age_moyen(OUT AGE_MOYEN INT) 
BEGIN
	SET AGE_MOYEN := (SELECT AVG(age) FROM PROFIL2);                
END;
//
DELIMITER ;

CALL age_moyen(@age_moyen);
SELECT @age_moyen;

-- ACTIVITE 5 --

--1--

DROP TRIGGER IF EXISTS date_creation;

DELIMITER //
CREATE TRIGGER date_creation
BEFORE INSERT ON t_profil_pfl
FOR EACH ROW
BEGIN
SET NEW.pfl_date = CURDATE();
END;
//
DELIMITER ;

INSERT INTO t_profil_pfl (pfl_nom, pfl_prenom, pfl_email, pfl_statut,pfl_validite,  pfl_date) VALUES ('le roy', 'emma', 'emma.leroy@exemple.com', 'M', 'O', '2024-10-10');

--2--

DROP TRIGGER IF EXISTS date_modification;

DELIMITER //
CREATE TRIGGER date_modification
AFTER UPDATE ON t_compte_cpt
FOR EACH ROW
BEGIN
UPDATE t_profil_pfl SET pfl_date = CURDATE() WHERE t_profil_pfl.pfl_id = NEW.pfl_id; 
END;
//
DELIMITER ;

UPDATE t_compte_cpt SET cpt_mot_de_passe='mo!dep@sse' WHERE cpt_pseudo = 'val29';


--3--

DROP TRIGGER IF EXISTS hashage_mdp;

DELIMITER //
CREATE TRIGGER hashage_mdp
BEFORE INSERT ON t_compte_cpt
FOR EACH ROW
BEGIN
SET NEW.cpt_mot_de_passe = SHA2(CONCAT('sel',NEW.cpt_mot_de_passe),256);
END;
//
DELIMITER ;

INSERT INTO t_compte_cpt (pfl_id,cpt_pseudo,cpt_mot_de_passe) VALUES (13,'emmalr','mo!dep@sse');

-- requêtes pour Olympix

--vues--
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

--fonction--

--procédure--
DROP PROCEDURE IF EXISTS mineur;

DELIMITER //
CREATE PROCEDURE date_crs(IN ID INT, OUT MESSAGE VARCHAR(10)) 
BEGIN
	DECLARE DATE_CONCOURS DATE;
    SET DATE_CONCOURS := (SELECT con_date_debut FROM t_concours_con WHERE con_id = ID);

   	IF (YEAR(DATE_CONCOURS)=YEAR(CURDATE()) AND MONTH(DATE_CONCOURS)>MONTH(CURDATE()) OR (YEAR(DATE_CONCOURS)=YEAR(CURDATE()) AND MONTH(DATE_CONCOURS)=MONTH(CURDATE()) AND DAY(DATE_CONCOURS)>=DAY(CURDATE()))) THEN
		SET MESSAGE := "Le concours a commencé";	
	ELSE
		SET MESSAGE := "Le concours n'a pas encore commencé";
	END IF;

                 
END;
//
DELIMITER ;

--triggers--
DROP TRIGGER IF EXISTS incr_note;

DELIMITER //
CREATE TRIGGER incr_note
AFTER INSERT ON T_JURY_CANDIDATURE_jcd
FOR EACH ROW
BEGIN
UPDATE T_CANDIDATURE_cdt SET cdt_note_finale = cdt_note_finale + jcd_note WHERE T_CANDIDATURE_cdt.cdt_id = NEW.cdt_id;
END;
//
DELIMITER ;

DROP TRIGGER IF EXISTS hash_salt_mdp;
DELIMITER // CREATE TRIGGER hash_salt_mdp BEFORE
UPDATE ON t_compte_cpt FOR EACH ROW BEGIN
SET NEW.cpt_mdp = SHA2(CONCAT(NEW.cpt_mdp, 'monsel524'), 256);
END;
// DELIMITER;
