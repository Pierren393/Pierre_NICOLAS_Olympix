DELIMITER // 
CREATE PROCEDURE supprimer_candidature(IN CODE_DOSSIER CHAR(20), IN CODE_CANDIDATURE CHAR(8)) 
BEGIN 
SET @ID_CANDIDAT := (
    SELECT can_id FROM t_candidature_can 
WHERE can_dossier = CODE_DOSSIER AND can_code = CODE_CANDIDATURE); 
DELETE FROM t_ressource_res WHERE can_id = @ID_CANDIDAT; 
DELETE FROM t_candidature_can WHERE can_id = @ID_CANDIDAT; 
END; 
// 
DELIMITER ; 
CALL supprimer_candidature(CODE_DOSSIER, CODE_CANDIDATURE); 
-- Actualités :
-- sprint 1
-- 1. Requête listant toutes les actualités de la table des actualités et leur auteur
-- (login)
select
    act_id,
    act_titre,
    cpt_login
from
    t_actualite_act
    join t_concours_con USING (con_id);

-- 2. Requête donnant les données d'une actualité dont on connaît l'identifiant (n°)
select
    *
from
    t_actualite_act
where
    act_id = '1';

-- 3. Requête listant les 5 dernières actualités dans l'ordre décroissant
select
    *
from
    t_actualite_act
order by
    act_id DESC
limit
    5;

-- 4. Requête recherchant et donnant la (ou les) actualité(s) contenant un mot
-- particulier
select
    *
from
    t_actualite_act
where
    act_description LIKE '%@%'
    OR act_titre LIKE '%@%';

-- 5. Requête listant toutes les actualités postées à une date particulière + le login de
-- l’auteur
select
    act_id,
    act_titre,
    act_date,
    cpt_login
from
    t_actualite_act
    join t_concours_con USING (con_id)
where
    DATE (act_date) = '2024-09-01';

-- Concours :
-- sprint 1
-- 1. Requête listant tous les concours de la plateforme (passés, en cours, à venir)
select
    con_id,
    con_nom
from
    t_concours_con;

-- 2. Requête (+code SQL) listant tous les concours de la plateforme (passés, en
-- cours, à venir) avec leurs principales caractéristiques (organisateur responsable,
-- date de début, dates intermédiaires, catégories, nom, prénom et discipline des
-- juges)
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
select t_jury_jur.cpt_login,cpt_nom,cpt_prenom, con_id,jur_id 
FROM t_compte_cpt 
JOIN t_jury_jur USING (cpt_login) 
JOIN t_concours_con_has_t_jury_jur2 USING(jur_id)
JOIN t_concours_con USING(con_id)

SELECT
    con_id,
    t_candidature_can.cat_id,
    cat_nom,
    etat_concours(con_id),
    t_concours_con.cpt_login,
    con_date_debut,
    con_nb_jours_candidature,
    con_nb_jours_preselection,
    con_nb_jours_finale,
    ADDDATE(con_date_debut, con_nb_jours_candidature ) AS date_preselection,
    ADDDATE(ADDDATE(con_date_debut, con_nb_jours_candidature), con_nb_jours_preselection) AS date_finale,
    cpt_nom,
    cpt_prenom
FROM
    t_concours_con
    JOIN t_choix_cho USING (con_id)
    JOIN t_categorie_cat USING (cat_id)
    JOIN t_candidature_can USING (con_id)
    JOIN t_note_not USING (can_id)
    JOIN t_jury_jur USING (jur_id)
    JOIN t_compte_cpt USING(t_compte_cpt.cpt_login);

DROP FUNCTION IF EXISTS donner_listejury;

DELIMITER //
CREATE FUNCTION donner_listejury(ID INT) RETURNS TEXT 
BEGIN
    DECLARE JURY VARCHAR(120);
SET JURY := (SELECT GROUP_CONCAT(CONCAT(cpt_nom, ' ', cpt_prenom) SEPARATOR '<br/>')
    AS jury
FROM t_compte_cpt 
JOIN t_jury_jur USING (cpt_login) 
JOIN t_concours_con_has_t_jury_jur2 USING(jur_id)
JOIN t_concours_con USING(con_id)
            WHERE con_id = ID);
   
RETURN JURY;
  
END;
//
DELIMITER ;
SELECT donner_listejury(1);
DROP FUNCTION IF EXISTS donner_listecategorie;

DELIMITER //
CREATE FUNCTION donner_listecategorie(ID INT) RETURNS TEXT 
BEGIN
    DECLARE CATEGORIE VARCHAR(120);
SET CATEGORIE := (SELECT GROUP_CONCAT(CONCAT(cat_nom, '') SEPARATOR '<br/>')
    AS categorie
from t_categorie_cat
JOIN t_choix_cho USING(cat_id)
JOIN t_concours_con USING(con_id)
where con_id = ID);
   
RETURN CATEGORIE;
  
END;
//
DELIMITER ;
SELECT donner_listecategorie(1);

SELECT
t_concours_con.cpt_login as organisateur,        
etat_concours(con_id) as etat,
donner_listecategorie(con_id) as categorie,
 con_date_debut,
        con_nb_jours_candidature,
        con_nb_jours_preselection,
        con_nb_jours_finale,
        ADDDATE(con_date_debut, con_nb_jours_candidature) AS date_preselection,
        ADDDATE(ADDDATE(con_date_debut, con_nb_jours_candidature), con_nb_jours_preselection) AS date_finale,
       donner_listejury(con_id) as jury,   
       con_id,
        t_candidature_can.cat_id,
        con_discipline
    FROM
        t_concours_con
      LEFT  JOIN t_choix_cho USING (con_id)
      LEFT  JOIN t_categorie_cat USING (cat_id)
        LEFT JOIN t_candidature_can USING (con_id)
    LEFT  JOIN t_note_not USING (can_id)
     LEFT   JOIN t_jury_jur USING (jur_id)
       LEFT JOIN t_compte_cpt ON t_jury_jur.cpt_login = t_compte_cpt.cpt_login
        
group by con_id;

----------------------------------------------------------------
-- donner categorie,concours et phase, date_phase
-- 3. Requête listant les concours qui ont débuté et leur phase actuelle (ex : finale)
select
    etat_concours (con_id),
    con_id,
    con_nom
from
    t_concours_con
where
    etat_concours (con_id) != 'A venir';

-- 4. Requête listant les concours à venir avec leur date de début
select
    etat_concours (con_id),
    con_id,
    con_nom,
    con_date_debut
from
    t_concours_con
where
    etat_concours (con_id) = 'A venir';

-- 5. Requête donnant toutes les caractéristiques d’un concours particulier (ID connu)
select
    *
from
    t_concours_con
where
    con_id = '1';

-- 6. Requête donnant les informations des membres du jury d’un concours particulier
-- (ID connu)
select
    *
from
    t_concours_con
where
    con_id = '1';

-- 7. Requête listant tous les membres de jury, classés par discipline, pour tous les
-- concours de la plateforme
select
    t_concours_con.cpt_login,
    con_discipline
from
    t_concours_con
    join t_concours_con_has_t_jury_jur2 using (con_id)
    join t_jury_jur using (jur_id)
order by
    con_discipline
    -- sprint 2
    -- 8. Requête donnant la liste des catégories d’un concours particulier (ID connu)
select
    con_id,
    con_nom,
    cat_nom
from
    t_concours_con
    join t_choix_cho using (con_id)
    join t_categorie_cat using (cat_id)
where
    con_id = '1';

-- 9. Requête listant de tous les administrateurs de la plateforme et les concours dont
-- il est (/a été) responsable, s’il y en a
select
    cpt_login
from
    t_administrateur_adm
    join t_compte_cpt using (cpt_login)
    join t_concours_con using (cpt_login)
    -------------------------------------------------------
    -------------------------------------------------------
    -------------------------------------------------------
    -------------------------------------------------------
    -- 10. Requête(s) listant tous les candidats pré-sélectionnés pour un concours
    -- particulier (ID connu) avec leurs principales données (nom, prénom, catégorie,
    -- date d’inscription, nombre de documents ressources téléversés)
select DISTINCT
    can_id,
    can_nom,
    can_prenom,
    can_retenue,
    con_id,
    COUNT(res_id) as nb_ressources
from
    t_concours_con
    join t_choix_cho using (con_id)
    join t_categorie_cat using (cat_id)
    join t_candidature_can using (con_id)
    join t_ressource_res USING (can_id)
where
    can_retenue = 'R';

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-- 11. Requête(s) listant tous les candidats pré-sélectionnés classés par catégorie pour
-- un concours particulier (ID connu)
select
	t_concours_con.con_id,
	cat_id,
    cat_nom,
    can_nom,
    can_prenom
from
    t_concours_con
    join t_choix_cho using (con_id)
	join t_categorie_cat using(cat_id)
    join t_candidature_can using(cat_id)
where
	 t_concours_con.con_id = '2' AND t_candidature_can.con_id = '2'  AND can_retenue = 'R';
    -------------------------------------------------------
    -------------------------------------------------------
    -------------------------------------------------------
    -------------------------------------------------------
    -- 12. Requête donnant tous les noms des documents ressources d’un candidat (ID
    -- connu) pour un concours particulier (ID connu)
select
    con_id,
    can_id,
    can_nom,
    can_prenom,
    res_nom,
    res_id
from
    t_concours_con
    join t_candidature_can using (con_id)
    join t_ressource_res using (can_id)
where
    con_id = '3'
    AND can_id = '1';

-- 13. Requête donnant le palmarès d’un concours particulier (ID connu) pour lequel la
-- phase finale est terminée
select
    con_id,
    can_id,
    not_note
from
    t_concours_con
    join t_candidature_can using (con_id)
    join t_note_not using (can_id)
where
    etat_concours (con_id) = 'Terminé'
    AND con_id = '1'
order by
    not_note desc
    -- 14. Requête donnant les palmarès ( nom / prénom / rang des 3 vainqueurs) des⇒
    -- concours terminés (sans tenir compte des notes des juges au profil désactivé)
SELECT
    con_id,
    can_nom,
    can_prenom,
    not_note,
    palmares
FROM
    (
        SELECT
            con_id,
            can_nom,
            can_prenom,
            not_note,
            RANK() OVER (
                PARTITION BY
                    con_id
                ORDER BY
                    not_note DESC
            ) AS palmares
        FROM
            t_concours_con
            JOIN t_candidature_can USING (con_id)
            JOIN t_note_not USING (can_id)
            JOIN t_jury_jur USING (jur_id)
            JOIN t_compte_cpt ON t_jury_jur.cpt_login = t_compte_cpt.cpt_login
        WHERE
            etat_concours (con_id) = 'Terminé'
            AND cpt_etat = 'A'
    ) AS classement
WHERE
    palmares <= 3
ORDER BY
    con_id,
    palmares
    -- Inscription (ou candidature) :
    -- sprint 1
    -- 1. Requête vérifiant l’existence du couple de codes (identification / inscription)
select
    count(*) as existe
from
    t_candidature_can
where
    can_code = 'K5l6M7n8'
    AND can_dossier = 'x6tBdUF6f477x3Wa5cVU';

-- 2. Requête d’affichage, si autorisé, de toutes les informations associées à une
-- inscription connaissant le couple de code d’identification / code d’inscription
select
    *
from
    t_candidature_can
where
    can_code = 'K5l6M7n8'
    AND can_dossier = 'x6tBdUF6f477x3Wa5cVU';

-- sprint 2
-- 3. Requête(s) d’insertion de toutes les données d’un candidat et de sa candidature,
-- y compris ses documents ressources et sa catégorie
INSERT INTO
    `t_candidature_can` (
        `can_id`,
        `can_code`,
        `can_dossier`,
        `can_prenom`,
        `can_nom`,
        `can_mail`,
        `can_retenue`,
        `can_date`,
        `can_etat`,
        `cat_id`,
        `con_id`
    )
VALUES
    (
        1,
        'AQSwdze4',
        'p5EFPm3fe5wXR28yS66c',
        'organisateur',
        'organisateur',
        'organisateur@Olympix.com',
        'R',
        '2024-10-05',
        'A',
        1,
        3
    );

INSERT INTO
    `t_ressource_res` (
        `res_id`,
        `res_nom`,
        `res_description`,
        `res_chemin`,
        `res_type`,
        `can_id`
    )
VALUES
    (
        2,
        'Fichier musical',
        'Fichier audio pour le concours de musique',
        '/uploads/music1.mp3',
        2,
        2
    );

-- 4. Requête(s) de suppression d’une candidature connaissant le couple de code
-- d’identification / code d’inscription
DELETE FROM t_ressource_res
WHERE
    can_id IN (
        SELECT
            can_id
        FROM
            t_candidature_can
        WHERE
            can_code = 'K5l6M7n8'
            AND can_dossier = 'x6tBdUF6f477x3Wa5cVU'
    );

DELETE FROM t_note_not
WHERE
    can_id IN (
        SELECT
            can_id
        FROM
            t_candidature_can
        WHERE
            can_code = 'K5l6M7n8'
            AND can_dossier = 'x6tBdUF6f477x3Wa5cVU'
    );

DELETE FROM t_candidature_can
WHERE
    can_code = 'K5l6M7n8'
    AND can_dossier = 'x6tBdUF6f477x3Wa5cVU';

-- Profils (administrateurs / me&mbres du jury) :
-- sprint 1
-- 1. Requête listant toutes les données de tous les profils classés par statut
SELECT
    *
FROM
    t_compte_cpt
    LEFT JOIN t_administrateur_adm USING (cpt_login)
    LEFT JOIN t_jury_jur USING (cpt_login)
ORDER BY
    `t_administrateur_adm`.`adm_etat` DESC;

-- 2. Requête de vérification des données de connexion (login et mot de passe)
SELECT
    cpt_login,
    cpt_mdp
FROM
    t_compte_cpt
WHERE
    cpt_login = 'organisateur@Olympix.com'
    AND cpt_mdp = SHA2 ('org24*PMYLO', 512);

-- 3. Requête récupérant les données d'un profil particulier (utilisateur connecté)
SELECT
    *
FROM
    t_compte_cpt
    LEFT JOIN t_administrateur_adm USING (cpt_login)
    LEFT JOIN t_jury_jur USING (cpt_login)
where
    cpt_login = 'organisateur@Olympix.com';

-- 4. Requête de mise à jour du mot de passe d'un profil
UPDATE `t_compte_cpt`
SET
    `cpt_mdp` = SHA2 ('org24*PMYLO', 512)
WHERE
    `t_compte_cpt`.`cpt_login` = 'marcel.decheval@Olympix.com';

-- 5. Requête d'ajout des données d'un profil administrateur (/ membre du jury)
INSERT INTO
    `t_compte_cpt` (
        `cpt_login`,
        `cpt_mdp`,
        `cpt_nom`,
        `cpt_prenom`,
        `cpt_etat`
    )
VALUES
    (
        'test@Olympix.com',
        '7c2aabafabe45089defe35077226a61801c8826dde611d162658db75cff0fc73eab177a3cb9e0a2f3c906730e6f1e5a68e0c818dbd98f4ff5539f9eb02e01a3b',
        'terminal',
        'terminal',
        'A'
    );

INSERT INTO
    `t_administrateur_adm` (`adm_id`, `adm_etat`, `cpt_login`)
VALUES
    (NULL, 'A', 'test@Olympix.com');

----
INSERT INTO
    `t_compte_cpt` (
        `cpt_login`,
        `cpt_mdp`,
        `cpt_nom`,
        `cpt_prenom`,
        `cpt_etat`
    )
VALUES
    (
        'test@Olympix.com',
        '7c2aabafabe45089defe35077226a61801c8826dde611d162658db75cff0fc73eab177a3cb9e0a2f3c906730e6f1e5a68e0c818dbd98f4ff5539f9eb02e01a3b',
        'terminal',
        'terminal',
        'A'
    );

INSERT INTO
    `t_jury_jur` (
        `jur_id`,
        `jur_biographie`,
        `jur_url`,
        `jur_domaine_expertise`,
        `cpt_login`
    )
VALUES
    (
        NULL,
        'Biographie Jury Littérature',
        'http://jury-litterature.com',
        'Littérature',
        'test@Olympix.com'
    );

-- 6. Requête de désactivation d'un profil
UPDATE `t_compte_cpt`
SET
    `cpt_etat` = 'D'
WHERE
    `t_compte_cpt`.`cpt_login` = 'martin.sophie@Olympix.com';

-- 7. Requête(s) de suppression d’un profil administrateur / membre de jury et des
-- données associées à ce profil (sans supprimer les données d’un concours
-- démarré !)
--Administrateur
DELETE FROM t_actualite_act
WHERE
    con_id IN (
        SELECT
            con_id
        FROM
            t_concours_con
        WHERE
            cpt_login = 'test@Olympix.com'
    );

DELETE FROM t_administrateur_adm
WHERE
    cpt_login = 'test@Olympix.com';

DELETE FROM t_compte_cpt
WHERE
    `t_compte_cpt`.`cpt_login` = 'test@Olympix.com';

--Jury
DELETE from t_note_not
where
    jur_id = (
        select
            jur_id
        from
            t_jury_jur
        where
            cpt_login = 'bernard.alice@Olympix.com'
    )
DELETE FROM t_jury_jur
WHERE
    `t_jury_jur`.`cpt_login` = 'bernard.alice@Olympix.com';

DELETE from t_message_mes
where
    jur_id = (
        select
            jur_id
        from
            t_jury_jur
        where
            cpt_login = 'bernard.alice@Olympix.com'
    );

DELETE FROM t_compte_cpt
WHERE
    `t_compte_cpt`.`cpt_login` = 'bernard.alice@Olympix.com';

-- Concours / catégories / membres du jury / [+ disciplines] :
-- sprint 2
-- 1. Requête listant tous les concours ordonnés par leur date de début
select
    con_id,
    con_date_debut
from
    t_concours_con
order by
    con_date_debut ASC;

-- 2. Requête listant tous les concours et leur(s) catégorie(s) et juges, s’il y en a
select
    con_id,
    jur_id,
    cat_nom
from
    t_concours_con
    join t_choix_cho using (con_id)
    join t_categorie_cat using (cat_id)
    join t_concours_con_has_t_jury_jur2 using (con_id)
    -- 3. Requête permettant à l’administrateur connecté l’insertion d’un concours et de
    -- ses données générales
INSERT INTO
    `t_concours_con` (
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
    (
        1,
        '2024 vmvm!!!',
        '2024-09-01 10:00:00',
        9,
        3,
        'Photographie',
        120,
        5,
        'photo_concours.jpg',
        'organisateur@Olympix.com'
    );

-- Pré-sélection des candidats et sélection des finalistes :
-- En tant
-- qu’administrateur
-- sprint 2
-- 1. Requête donnant la liste des concours démarrés qui n’ont pas encore enregistré
-- d’inscription
select
    con_id,
    can_id
from
    t_concours_con
    left join t_candidature_can using (con_id)
where
    etat_concours (con_id) = 'Inscriptions'
    AND can_id is NULL;

-- 2. Requête listant toutes les candidatures classées par concours
select
    con_id,
    can_id
from
    t_concours_con
    join t_candidature_can using (con_id)
ORDER BY
    `t_concours_con`.`con_id` ASC;

-- 3. Requête listant toutes les candidatures pour un concours particulier
select
    con_id,
    can_id
from
    t_concours_con
    join t_candidature_can using (con_id)
where
    con_id = '1'
ORDER BY
    `t_concours_con`.`con_id` ASC;

-- 4. Requête listant toutes les candidatures par catégorie pour un concours particulier
-- 5. Requête listant les candidatures d’un concours particulier selon leur état
select
    con_id,
    can_id,
    can_etat
from
    t_concours_con
    join t_candidature_can using (con_id)
where
    con_id = '1'
    AND can_etat = 'A'
ORDER BY
    `t_concours_con`.`con_id` ASC;

-- 6. Requête donnant la liste des candidatures faites non pré-sélectionnées pour un
-- concours particulier en phase de pré-sélection
select
    con_id,
    can_id,
    can_etat
from
    t_concours_con
    join t_candidature_can using (con_id)
where
    con_id = '1'
    AND can_retenue = 'I' -- Si le candidat est non-préselectionné alors son can_retenue reste sur I
ORDER BY
    `t_concours_con`.`con_id` ASC;

-- 7. Requête (ou code SQL) modifiant l’état d’une candidature (ID connu)
UPDATE t_candidature_can
SET
    can_etat = 'D'
WHERE
    can_id = 1;

-- 8. Requête donnant toutes les informations d’un candidat à partir de son ID (/ou de
-- son code d’inscription au concours)
select
    *
from
    t_candidature_can
where
    can_id = 1;

select
    *
from
    t_candidature_can
where
    can_code = "AQSwdze4";

select
    *
from
    t_candidature_can
where
    can_dossier = "p5EFPm3fe5wXR28yS66c";

-- 9. Requête listant toutes les candidatures pré-sélectionnées classées par concours
-- que le membre du jury connecté doit évaluer
select
    can_id,
    con_id,
    con_nom,
    can_retenue,
    can_nom,
    can_prenom,
    jur_id
from
    t_candidature_can
    join t_concours_con using (con_id)
    join t_concours_con_has_t_jury_jur2 using(con_id)
    join t_jury_jur using(jur_id)
where
    can_retenue = 'R' AND jur_id = '2';


-- 10. Requête pour vérifier si le juge connecté a déjà mis ses 4 points (/ 3 ou 2 points)
select
    not_note
from
    t_note_not
    join t_jury_jur using (jur_id)
where
    cpt_login = 'bernard.alice@Olympix.com'
    AND not_note = 4;

select
    not_note
from
    t_note_not
    join t_jury_jur using (jur_id)
where
    cpt_login = 'bernard.alice@Olympix.com'
    AND not_note = 3;

select
    not_note
from
    t_note_not
    join t_jury_jur using (jur_id)
where
    cpt_login = 'bernard.alice@Olympix.com'
    AND not_note = 2;

-- 11. Requête permettant au juge connecté d’attribuer une note à une candidature
INSERT INTO
    `t_note_not` (`can_id`, `jur_id`, `not_note`)
VALUES
    (1, 1, 1),
    -- 12. Requête permettant au juge connecté de modifier sa note pour une candidature
UPDATE `t_note_not`
SET
    `not_note` = '3'
WHERE
    `t_note_not`.`can_id` = 8
    AND `t_note_not`.`jur_id` = (
        select
            jur_id
        from
            t_jury_jur
        where
            cpt_login = 'durand.pierre@Olympix.com'
    );

