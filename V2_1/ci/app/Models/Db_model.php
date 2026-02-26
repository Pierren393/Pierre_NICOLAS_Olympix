<?php

namespace App\Models;

use CodeIgniter\Model;

class Db_model extends Model
{
    protected $db;
    public function __construct()
    {
        $this->db = db_connect(); //charger la base de données
        // ou
        //$this->db = \Config\Database::connect();
    }

    /*==================================================================
    Fonction de la table t_compte_cpt
    ==================================================================*/


    //Récupère tout les comptes 
    public function get_all_compte()
    {
        $resultat = $this->db->query("SELECT * 
        FROM t_compte_cpt 
        LEFT JOIN t_administrateur_adm USING(cpt_login) 
        LEFT JOIN t_jury_jur USING(cpt_login) 
        ORDER BY adm_id DESC;");
        return $resultat->getResultArray();
    }
    //Récupère un compte en fonction de son login
    public function get_compte($username)
    {
        $resultat = $this->db->query("SELECT * 
                                            FROM t_compte_cpt 
                                            LEFT JOIN t_administrateur_adm USING(cpt_login) 
                                            LEFT JOIN t_jury_jur USING(cpt_login) 
                                            WHERE cpt_login = '" . $username . "';");
        return $resultat->getRow();
    }
    //Récupère le nombre de comptes dans la base
    public function get_nb_comptes()
    {
        $requete = "SELECT count(*) as nb_comptes FROM t_compte_cpt;";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }
    //Insertion d'un compte 
    public function set_compte($saisie)
    {
        //Récuparation (+ traitement si nécessaire) des données du formulaire
        $login = $saisie['pseudo'];
        $nom = $saisie['nom'];
        $prenom = $saisie['prenom'];
        $mot_de_passe = $saisie['mdp'];
        $requete = "INSERT INTO t_compte_cpt VALUES('" . htmlspecialchars(addslashes($login)) . "@Olympix.com', '" . htmlspecialchars(addslashes($mot_de_passe)) . "', '" . htmlspecialchars(addslashes($nom)) . "', '" . htmlspecialchars(addslashes($prenom)) . "', 'A');";
        return $this->db->query($requete);
    }
    //Insertion d'un compte administrateur(organisateur)
    public function set_compte_profil_admin($saisie)
    {
        //Récuparation (+ traitement si nécessaire) des données du formulaire
        $login = $saisie['login'];
        $nom = $saisie['nom'];
        $prenom = $saisie['prenom'];
        $mot_de_passe = $saisie['mdp'];
        $etat = $saisie['etat'];
        $requete = "INSERT INTO t_compte_cpt (cpt_login, cpt_mdp, cpt_nom, cpt_prenom, cpt_etat)
                    VALUES (
                        '" . htmlspecialchars(addslashes($login)) . "',
                        SHA2('" . htmlspecialchars(addslashes($mot_de_passe)) . "', 512),
                        '" . htmlspecialchars(addslashes($nom)) . "',
                        '" . htmlspecialchars(addslashes($prenom)) . "',
                         '" . htmlspecialchars(addslashes($etat)) . "'
                    );";
        $requete2 = "INSERT INTO t_administrateur_adm (adm_etat, cpt_login) 
                    VALUES (
                        '" . htmlspecialchars(addslashes($etat)) . "',
                        '" . htmlspecialchars(addslashes($login)) . "'
                    );";

        $this->db->query($requete);
        return $this->db->query($requete2);
    }
    //Insertion d'un compte jury
    public function set_compte_profil_jury($saisie)
    {
        //Récuparation (+ traitement si nécessaire) des données du formulaire
        $login = $saisie['login'];
        $nom = $saisie['nom'];
        $prenom = $saisie['prenom'];
        $mot_de_passe = $saisie['mdp'];
        $etat = $saisie['etat'];
        $requete = "INSERT INTO t_compte_cpt (cpt_login, cpt_mdp, cpt_nom, cpt_prenom, cpt_etat)
                    VALUES (
                        '" . htmlspecialchars(addslashes($login)) . "',
                        SHA2('" . htmlspecialchars(addslashes($mot_de_passe)) . "', 512),
                        '" . htmlspecialchars(addslashes($nom)) . "',
                        '" . htmlspecialchars(addslashes($prenom)) . "',
                         '" . strtoupper(htmlspecialchars(addslashes($etat))) . "'
                    );";
        $requete2 = "INSERT INTO t_jury_jur (`jur_id`, `jur_biographie`, `jur_url`, `jur_domaine_expertise`, `cpt_login`) 
                    VALUES (NULL, '', '', '',  '" . htmlspecialchars(addslashes($login)) . "');   
                    ";

        $this->db->query($requete);
        return $this->db->query($requete2);
    }
    //Changement des infos d'un compte administrateur(organisateur)
    public function set_compte_admin($prenom, $nom, $mdp, $username)
    {
        //Récuparation (+ traitement si nécessaire) des données du formulaire

        $requete = "UPDATE `t_compte_cpt`
                SET
                    `cpt_prenom` = '" . htmlspecialchars(addslashes($prenom)) . "',
                    `cpt_nom` = '" . htmlspecialchars(addslashes($nom)) . "',
                    `cpt_mdp` = SHA2 ('" . htmlspecialchars(addslashes($mdp)) . "', 512)
                WHERE
                    `t_compte_cpt`.`cpt_login` = '" . htmlspecialchars(addslashes($username)) . "';";
        return $this->db->query($requete);
    }
    //Changement des infos d'un compte jury
    public function set_compte_jury($prenom, $nom, $mdp, $email, $discipline, $biographie, $url, $username)
    {
        //Récuparation (+ traitement si nécessaire) des données du formulaire
        $requete = "UPDATE `t_compte_cpt`
                SET
                    `cpt_prenom` = '" . htmlspecialchars(addslashes($prenom)) . "',
                    `cpt_nom` = '" . htmlspecialchars(addslashes($nom)) . "',
                    `cpt_mdp` = SHA2 ('" . htmlspecialchars(addslashes($mdp)) . "', 512)
                WHERE
                    `t_compte_cpt`.`cpt_login` = '" . htmlspecialchars(addslashes($username)) . "';";
        $requete2 = " UPDATE `t_jury_jur`
                SET
                    `jur_biographie` = '" . htmlspecialchars(addslashes($biographie)) . "',
                    `jur_domaine_expertise` = '" . htmlspecialchars(addslashes($discipline)) . "',
                    `jur_url` ='" . htmlspecialchars(addslashes($url)) . "'
                WHERE
                    `t_jury_jur`.`cpt_login` = '" . htmlspecialchars(addslashes($username)) . "';";
        $this->db->query($requete);
        return $this->db->query($requete2);
    }
    //Vérification qu'un compte se trouve bien dans la base
    public function connect_compte($u, $p)
    {
        $sql = "SELECT cpt_login,cpt_mdp
        FROM t_compte_cpt
        WHERE cpt_login='" . htmlspecialchars(addslashes($u)) . "'
        AND cpt_mdp = SHA2('" . htmlspecialchars(addslashes($p)) . "',512);";
        $resultat = $this->db->query($sql);
        if ($resultat->getNumRows() > 0) {
            return true;
        } else {
            return false;
        }
    }
    //Récupère les concours pour le jury
    public function get_jury_concours()
    {
        $requete = "SELECT
                t_concours_con.cpt_login as organisateur,        
                etat_concours(con_id) as etat,
                donner_listecategorie(con_id) as categorie,
                donner_listediscipline(con_id) as discipline,
                con_date_debut,
                con_nb_jours_candidature,
                con_nb_jours_preselection,
                con_nb_jours_finale,
                ADDDATE(con_date_debut, con_nb_jours_candidature) AS date_preselection,
                ADDDATE(ADDDATE(con_date_debut, con_nb_jours_candidature), con_nb_jours_preselection) AS date_finale,
                donner_listejury(con_id) as jury,   
                con_id,
                t_candidature_can.cat_id,
                con_nom,
                con_description
            FROM
                t_concours_con
            LEFT JOIN t_choix_cho USING (con_id)
            LEFT JOIN t_categorie_cat USING (cat_id)
            LEFT JOIN t_candidature_can USING (con_id)
            LEFT JOIN t_note_not USING (can_id)
            LEFT JOIN t_jury_jur USING (jur_id)
            LEFT JOIN t_compte_cpt ON t_jury_jur.cpt_login = t_compte_cpt.cpt_login
                
            group by con_id
            order by con_date_debut";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }
    /*==================================================================
    Fonction de la table t_actualite_act
    ==================================================================*/

    //Récupère une actualité en fonction de son id
    public function get_actualite($numero)
    {
        $requete = "SELECT * FROM t_actualite_act WHERE act_id=" . htmlspecialchars(addslashes($numero)) . ";";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }
    //Récupère toutes les actualités
    public function get_all_actualite()
    {
        $requete = "SELECT *, DAY(act_date) FROM t_actualite_act JOIN t_concours_con using(con_id) WHERE act_etat = 'A' ORDER BY act_date DESC LIMIT 5
        ;";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }
    /*==================================================================
    Fonction de la table t_concours_con
    ==================================================================*/

    //Récupère tout les concours avec leurs infos liées
    public function get_all_concours()
    {
        $requete = "SELECT
        t_concours_con.cpt_login as organisateur,        
        etat_concours(con_id) as etat,
        donner_listecategorie(con_id) as categorie,
        donner_listediscipline(con_id) as discipline,
        con_date_debut,
        con_nb_jours_candidature,
        con_nb_jours_preselection,
                con_nb_jours_finale,
                ADDDATE(con_date_debut, con_nb_jours_candidature) AS date_preselection,
                ADDDATE(ADDDATE(con_date_debut, con_nb_jours_candidature), con_nb_jours_preselection) AS date_finale,
               donner_listejury(con_id) as jury,   
               con_id,
                t_candidature_can.cat_id,
                con_nom,
                con_id,
                con_description
                
            FROM
                t_concours_con
            LEFT JOIN t_choix_cho USING (con_id)
            LEFT JOIN t_categorie_cat USING (cat_id)
            LEFT JOIN t_candidature_can USING (con_id)
            LEFT JOIN t_note_not USING (can_id)
            LEFT JOIN t_jury_jur USING (jur_id)
            LEFT JOIN t_compte_cpt ON t_jury_jur.cpt_login = t_compte_cpt.cpt_login
                
        group by con_id;";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }

    //Récupère un concours avec son id
    public function get_concours($id)
    {
        $requete = "SELECT
        t_concours_con.cpt_login as organisateur,        
        etat_concours(con_id) as etat,
        donner_listecategorie(con_id) as categorie,
        donner_listediscipline(con_id) as discipline,
        con_date_debut,
        con_nb_jours_candidature,
        con_nb_jours_preselection,
                con_nb_jours_finale,
                ADDDATE(con_date_debut, con_nb_jours_candidature) AS date_preselection,
                ADDDATE(ADDDATE(con_date_debut, con_nb_jours_candidature), con_nb_jours_preselection) AS date_finale,
               donner_listejury(con_id) as jury,   
               con_id,
                t_candidature_can.cat_id,
                con_nom,
                con_discipline,
                con_description
                
            FROM
                t_concours_con
            LEFT JOIN t_choix_cho USING (con_id)
            LEFT JOIN t_categorie_cat USING (cat_id)
            LEFT JOIN t_candidature_can USING (con_id)
            LEFT JOIN t_note_not USING (can_id)
            LEFT JOIN t_jury_jur USING (jur_id)
            LEFT JOIN t_compte_cpt ON t_jury_jur.cpt_login = t_compte_cpt.cpt_login
            where con_id = '" . $id . "'
        group by con_id;";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }


    /*==================================================================
    Fonction de la table t_candidature_can
    ==================================================================*/
    //Récupère toutes les candiatures 
    public function get_all_candidats()
    {
        $requete = "SELECT  * from  t_candidature_can ;";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }
    //Récupère une candidature en fonction de son id
    public function get_candidat_w_id($can_id)
    {
        $requete = "SELECT * FROM t_candidature_can JOIN t_concours_con USING(con_id) JOIN t_categorie_cat USING(cat_id)WHERE 
        can_id= '" . htmlspecialchars(addslashes($can_id)) . "';";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }
    //Récupère une candidature en fonction du code du dossier
    public function get_candidat($code_dossier)
    {
        $requete = "SELECT * FROM t_candidature_can JOIN t_concours_con USING(con_id) JOIN t_categorie_cat USING(cat_id)WHERE 
        can_dossier= '" . htmlspecialchars(addslashes($code_dossier)) . "' AND can_dossier= '" . htmlspecialchars(addslashes($code_dossier)) . "';";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }
    //Récupère une candidature avec ses documents en fonction du code du dossier
    public function get_documents_candidat($code_dossier)
    {
        $requete = "SELECT * FROM t_candidature_can JOIN t_ressource_res using(can_id) WHERE 
        can_dossier= '" . htmlspecialchars(addslashes($code_dossier)) . "';";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }
    //Récupère une candidature avec ses documents en fonction du code du dossier et de la candidature
    public function get_candidat_w_code($code_dossier, $code_can)
    {
        $requete = "SELECT * FROM t_candidature_can JOIN t_concours_con USING(con_id) JOIN t_categorie_cat USING(cat_id)WHERE 
        can_dossier= '" . htmlspecialchars(addslashes($code_dossier)) . "' AND can_code= '" . htmlspecialchars(addslashes($code_can)) . "';";
        $resultat = $this->db->query($requete);
        return $resultat->getRow();
    }
    //Requete pour supprimer un candidat
    public function del_candidat($code_dossier, $code_can)
    {
        $requete = "CALL supprimer_candidature('" . $code_dossier . "','" . $code_can . "')";
        return $this->db->query($requete);
    }
    //Requete pour recuperer les candidatures qui sont retenue avec leur categorie et concours
    public function get_candidat_concours_categorie($con_id)
    {
        $requete = "SELECT
                    t_concours_con.con_id,
                    cat_id,
                    cat_nom,
                    can_nom,
                    can_prenom,
                    can_id
                    from
                    t_concours_con
                    join t_choix_cho using (con_id)
                    join t_categorie_cat using(cat_id)
                    join t_candidature_can using(cat_id)
                    where
                    t_concours_con.con_id = '" . $con_id . "' AND t_candidature_can.con_id = '" . $con_id . "'  AND can_retenue = 'R'
                    order by cat_id;";
        $resultat = $this->db->query($requete);
        return $resultat->getResultArray();
    }


}

//sauvergarde sur obiwan vador et gitlab
//copie distante entre obiwan et vador
//copie en local 
//git ignore si erreur sur writable
//remettre le lien symbolique après avoir changer de version
