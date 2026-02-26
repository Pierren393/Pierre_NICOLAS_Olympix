<?php

namespace App\Controllers;

use App\Models\Db_model;

use CodeIgniter\Exceptions\PageNotFoundException;

class Compte extends BaseController
{
    protected $model;
    public function __construct()
    {
        helper('form');
        $this->model = model(Db_model::class);
    }
    public function lister()
    {
        $data['titre'] = "Liste de tous les comptes";
        $data['logins'] = $this->model->get_all_compte();
        $data['nb_comptes'] =  $this->model->get_nb_comptes();
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('affichage_comptes')
            . view('templates/bas');
    }
    public function creer()
    {

        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        if ($this->request->getMethod() == "post") {
            if (! $this->validate([
                'pseudo' => 'required|max_length[120]|min_length[2]',
                'nom' => 'required|max_length[80]|min_length[2]',
                'prenom' => 'required|max_length[80]|min_length[2]',
                'mdp' => 'required|max_length[300]|min_length[8]'
            ], [
                // Configuration des messages d’erreurs
                'pseudo' => [
                    'required' => 'Veuillez entrer un pseudo pour le compte !',
                    'min_length' => 'Le pseudo saisi est trop court !',
                ],
                'nom' => [
                    'required' => 'Veuillez entrer un nom !',
                    'min_length' => 'Le nom saisi est trop court !',
                ],
                'prenom' => [
                    'required' => 'Veuillez entrer prenom !',
                    'min_length' => 'Le prenom saisi est trop court !',
                ],
                'mdp' => [
                    'required' => 'Veuillez entrer un mot de passe !',
                    'min_length' => 'Le mot de passe saisi est trop court !',
                ],
            ])) {
                // La validation du formulaire a échoué, retour au formulaire !
                return view('templates/haut', ['titre' => 'Créer un compte'])
                    . view('templates/menu_visiteur')
                    . view('compte/compte_creer')
                    . view('templates/bas');
            }
            // La validation du formulaire a réussi, traitement du formulaire
            $recuperation = $this->validator->getValidated();
            $this->model->set_compte($recuperation);
            $data['le_compte'] = $recuperation['pseudo'];
            $data['le_message'] = "Nouveau nombre de comptes : ";
            //Appel de la fonction créée dans le précédent tutoriel :
            $data['le_total'] =  $this->model->get_nb_comptes();
            return view('templates/haut', $data)
                . view('compte/compte_succes')
                . view('templates/bas');
        }
        // L’utilisateur veut afficher le formulaire pour créer un compte
        return view('templates/haut', ['titre' => 'Créer un compte'])
            . view('templates/menu_visiteur')
            . view('compte/compte_creer')
            . view('templates/bas');
    }
    public function connecter()
    {
        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        if ($this->request->getMethod() == "post") {
            if (!$this->validate([
                'pseudo' => 'required|max_length[120]|min_length[2]',
                'mdp' => 'required|max_length[300]|min_length[8]'
            ], [
                // Configuration des messages d’erreurs
                'pseudo' => [
                    'required' => 'Identifiants erronés ou inexistants !',
                    'min_length' => 'Identifiants erronés ou inexistants !',
                ],
                'mdp' => [
                    'required' => 'Identifiants erronés ou inexistants !',
                    'min_length' => 'Identifiants erronés ou inexistants !',
                ]
            ])) {
                // La validation du formulaire a échoué, retour au formulaire !
                return view('templates/haut', ['titre' => 'Se connecter'])
                    . view('templates/menu_visiteur')
                    . view('connexion/compte_connecter')
                    . view('templates/bas');
            }

            // La validation du formulaire a réussi, traitement du formulaire
            $username = $this->request->getVar('pseudo');
            $password = $this->request->getVar('mdp');
            $data['compte'] = $this->model->get_compte($username);

            if ($this->model->connect_compte($username, $password) == true && $data['compte']->cpt_etat == 'A') {
                $session = session();
                $session->set('user', $username);
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_accueil',)
                    . view('templates/bas_admin');
            } else {
                $session = session();
                $session->setFlashdata('error', 'Identifiants erronés ou inexistants !') ;
                return view('templates/haut', ['titre' => 'Se connecter'])
                    . view('templates/menu_visiteur')
                    . view('connexion/compte_connecter')
                    . view('templates/bas');
            }
        }
                               

        $session = session();
        if ($session->has('user')) {
            $data['compte'] = $this->model->get_compte($session->get('user'));
            return view('templates/haut_admin', $data)
                . view('connexion/compte_accueil')
                . view('templates/bas_admin');
        } else {
            return view('templates/haut', ['titre' => 'Se connecter'])
                . view('templates/menu_visiteur')
                . view('connexion/compte_connecter')
                . view('templates/bas');
        }
    }
    public function afficher_profil()
    {
        $session = session();
        if ($session->has('user')) {
            $data['compte'] = $this->model->get_compte($session->get('user'));
            $data['le_message'] = "Affichage des données du profil ici !!!";
            $data['profil'] = $this->model->get_compte($session->get('user'));
            return view('templates/haut_admin', $data)
                . view('connexion/compte_profil')
                . view('templates/bas_admin');
        } else {
            $session->destroy();
            return view('templates/haut', ['titre' => 'Se connecter'])
                . view('templates/menu_visiteur')
                . view('connexion/compte_connecter')
                . view('templates/bas');
        }
    }
    public function deconnecter()
    {
        $session = session();
        $session->destroy();
        return view('templates/haut', ['titre' => 'Se connecter'])
            . view('templates/menu_visiteur')
            . view('connexion/compte_connecter')
            . view('templates/bas');
    }
    public function changer_mdp()
    {
        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));

        if ($this->request->getMethod() == "post" && $data['compte']->adm_id != null) {
            if (!$this->validate([
                'prenom' => 'required|max_length[80]|min_length[2]',
                'nom' => 'required|max_length[80]|min_length[2]',
                'mdp' => 'required|max_length[300]|min_length[8]',
                'mdp2' => 'required|max_length[300]|min_length[8]|matches[mdp]'
            ], [
                // Configuration des messages d’erreurs
                'prenom' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le prénom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 80 caractères.'

                ],
                'nom' => [
                    'required' => 'Champs de saisie vides !.',
                    'min_length' => 'Le nom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 80 caractères.'
                ],
                'mdp' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 300 caractères.'
                ],
                'mdp2' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 300 caractères.',
                    'matches' => 'Confirmation du mot de passe erronée, veuillez réessayer !'
                ]
            ])) {
                // La validation a échoué, renvoyer au formulaire
                $data['compte'] = $this->model->get_compte($session->get('user'));
                return view('templates/haut_admin', $data)
                    . view('compte/compte_changer_mdp', ['titre' => 'Modification du compte'])
                    . view('templates/bas_admin');
            }

            // La validation du formulaire a réussi, traitement du formulaire
            $prenom = $this->request->getVar('prenom');
            $nom = $this->request->getVar('nom');
            $mdp = $this->request->getVar('mdp');

            $username = $session->get('user');

            $this->model->set_compte_admin($prenom, $nom, $mdp, $username);

            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                $data['profil'] = $this->model->get_compte($session->get('user'));
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_profil', ['titre' => 'Modification(s) réussie(s)'])
                    . view('templates/bas_admin');
            } else {
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_profil')
                    . view('templates/bas_admin');
            }
        } else if ($this->request->getMethod() == "post" && $data['compte']->jur_id != null) {
            if (!$this->validate([
                'prenom' => 'required|max_length[80]|min_length[2]',
                'nom' => 'required|max_length[80]|min_length[2]',
                'email' => 'required|valid_email|max_length[120]',
                'discipline' => 'required|max_length[80]|min_length[1]',
                'biographie' => 'required|max_length[2000]|min_length[1]',
                'url' => 'max_length[120]|min_length[1]',
                'mdp' => 'required|max_length[300]|min_length[8]',
                'mdp2' => 'required|max_length[300]|min_length[8]|matches[mdp]'
            ], [
                // Configuration des messages d’erreurs
                'prenom' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le prénom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 80 caractères.'
                ],
                'nom' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le nom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le nom doit contenir au maximum 80 caractères.'
                ],
                'email' => [
                    'required' => 'Champs de saisie vides !',
                    'valid_email' => 'Adresse e-mail invalide.',
                    'max_length' => 'L’adresse e-mail doit contenir au maximum 120 caractères.'
                ],
                'discipline' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'La discipline doit contenir au moins 1 caractère.',
                    'max_length' => 'La discipline doit contenir au maximum 80 caractères.'
                ],
                'biographie' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'La biographie doit contenir au moins 1 caractère.',
                    'max_length' => 'La biographie doit contenir au maximum 2000 caractères.'
                ],
                'url' => [
                    'valid_url' => 'Champs de saisie vides !',
                    'min_length' => 'L’URL doit contenir au moins 1 caractère.',
                    'max_length' => 'L’URL doit contenir au maximum 300 caractères.'
                ],
                'mdp' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.'
                ],
                'mdp2' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.',
                    'matches' => 'Confirmation du mot de passe erronée, veuillez réessayer !'
                ]
            ])) {
                // La validation a échoué, renvoyer au formulaire
                $data['compte'] = $this->model->get_compte($session->get('user'));
                return view('templates/haut_admin', ['titre' => 'Modiffication du compte'], $data)
                    . view('compte/compte_changer_mdp', $data)
                    . view('templates/bas_admin');
            }

            // La validation a réussi
            $prenom = $this->request->getVar('prenom');
            $nom = $this->request->getVar('nom');
            $email = $this->request->getVar('email');
            $discipline = $this->request->getVar('discipline');
            $biographie = $this->request->getVar('biographie');
            $url = $this->request->getVar('url');
            $mdp = $this->request->getVar('mdp');

            $username = $session->get('user');

            $this->model->set_compte_jury($prenom, $nom, $mdp, $email, $discipline, $biographie, $url, $username);

            if ($data['compte']->cpt_etat == 'A' && $data['compte']->jur_id != null) {
                $session = session();
                $data['profil'] = $this->model->get_compte($session->get('user'));
                return view('templates/haut_admin', ['titre' => 'Modification(s) réussie(s)'], $data)
                    . view('connexion/compte_profil', $data)
                    . view('templates/bas_admin');
            } else {
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_profil')
                    . view('templates/bas_admin');
            }
        }
        // L’utilisateur veut afficher le formulaire pour changer de mot de passe

        if ($session->has('user')) {
            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                return view('templates/haut_admin', $data)
                    . view('compte/compte_changer_mdp', ['titre' => 'Modification du mot de passe'])
                    . view('templates/bas_admin');
            } else if ($data['compte']->cpt_etat == 'A' && $data['compte']->jur_id != null) {
                return view('templates/haut_admin',  $data)
                    . view('compte/compte_changer_mdp', ['titre' => 'Modification du profil'])
                    . view('templates/bas_admin');
            } else {
                $data['titre'] = "Actualités";
                $data['titre2'] = "Concours";
                $data['actualite'] =  $this->model->get_all_actualite();
                $data['concours'] =  $this->model->get_all_concours();
                return view('templates/haut', $data)
                    . view('templates/menu_visiteur')
                    . view('affichage_accueil')
                    . view('templates/bas');
            }
        } else {
            $data['titre'] = "Actualités";
            $data['titre2'] = "Concours";
            $data['actualite'] =  $this->model->get_all_actualite();
            $data['concours'] =  $this->model->get_all_concours();
            return view('templates/haut', $data)
                . view('templates/menu_visiteur')
                . view('affichage_accueil')
                . view('templates/bas');
        }
    }
    public function afficher_concours()
    {
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));

        if ($session->has('user')) {
            if ($data['compte']->jur_id != null) {
                $data['concours'] = $this->model->get_jury_concours();
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_concours', ['titre' => 'Concours'])
                    . view('templates/bas_admin');
            } elseif ($data['compte']->adm_id != null) {
                $data['allconcours'] = $this->model->get_all_concours();
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_concours', ['titre' => 'Concours'], $data)
                    . view('templates/bas_admin');
            }
        }
        return view('templates/haut', ['titre' => 'Se connecter'])
            . view('templates/menu_visiteur')
            . view('connexion/compte_connecter')
            . view('templates/bas');
    }
    public function afficher_comptes()
    {
        $session = session();
        $data['nb_comptes'] =  $this->model->get_nb_comptes();
        $data['compte'] = $this->model->get_compte($session->get('user'));
        $data['titre'] = "Liste de tous les comptes";
        $data['logins'] = $this->model->get_all_compte();
        if ($data['compte'] === null || $data['compte']->adm_id == null) {
            return redirect()->to(base_url(''));
        } else {
            return view('templates/haut_admin', $data)
                . view('connexion/compte_comptes')
                . view('templates/bas_admin');
        }
    }
    public function ajouter_profil()
    {
        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));

        if ($this->request->getMethod() == "post" && $data['compte']->adm_id != null) {
            if (!$this->validate([
                'login' => 'required|max_length[120]|min_length[5]|is_unique[t_compte_cpt.cpt_login]',
                'prenom' => 'required|max_length[80]|min_length[2]',
                'nom' => 'required|max_length[80]|min_length[2]',
                'mdp' => 'required|max_length[300]|min_length[8]',
                'statut' => 'required',
                'etat' => 'required',
                'mdp2' => 'required|max_length[300]|min_length[8]|matches[mdp]'
            ], [
                // Configuration des messages d’erreurs
                'login' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le login doit contenir au moins 6 caractères.',
                    'max_length' => 'Le login doit contenir au maximum 120 caractères.',
                    'is_unique' => 'Le compte ne peut pas être créé !'
                ],
                'prenom' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le prénom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 80 caractères.'
                ],
                'nom' => [
                    'required' => 'Champs de saisie vides !.',
                    'min_length' => 'Le nom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le nom doit contenir au maximum 80 caractères.'
                ],
                'mdp' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.'
                ],
                'statut' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le statut doit contenir 1 caractère.',
                    'max_length' => 'Le statut doit contenir 1 caractère.'
                ],
                'mdp2' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.',
                    'matches' => 'les 2 mots de passe saisis sont différents !!'
                ]
            ])) {
                // La validation du formulaire a échoué, retour au formulaire !
                return view('templates/haut_admin', $data)
                    . view('compte/compte_ajouter_compte', ['titre' => 'Ajouter un compte'])
                    . view('templates/bas_admin');
            }

            // La validation du formulaire a réussi, traitement du formulaire

            $recuperation = $this->validator->getValidated();
            if ($recuperation['statut'] == "administrateur") {
                $this->model->set_compte_profil_admin($recuperation);
            }
            if ($recuperation['statut'] == "jury") {
                $this->model->set_compte_profil_jury($recuperation);
            }

            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                $data['profil'] = $this->model->get_compte($recuperation['login']);
                $data['nb_comptes'] =  $this->model->get_nb_comptes();
                $data['compte'] = $this->model->get_compte($session->get('user'));
                $data['logins'] = $this->model->get_all_compte();
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_comptes', ['titre' => 'Compte créé'])
                    . view('templates/bas_admin');
            } else {
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_profil')
                    . view('templates/bas_admin');
            }
        }
        // L’utilisateur veut afficher le formulaire pour changer de mot de passe
        if ($session->has('user')) {
            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                return view('templates/haut_admin', $data)
                    . view('compte/compte_ajouter_compte', ['titre' => 'Ajouter un compte'])
                    . view('templates/bas_admin');
            } else {
                $data['titre'] = "Actualités";
                $data['titre2'] = "Concours";
                $data['actualite'] =  $this->model->get_all_actualite();
                $data['concours'] =  $this->model->get_all_concours();
                return view('templates/haut', $data)
                    . view('templates/menu_visiteur')
                    . view('affichage_accueil')
                    . view('templates/bas');
            }
        } else {
            $data['titre'] = "Actualités";
            $data['titre2'] = "Concours";
            $data['actualite'] =  $this->model->get_all_actualite();
            $data['concours'] =  $this->model->get_all_concours();
            return view('templates/haut', $data)
                . view('templates/menu_visiteur')
                . view('affichage_accueil')
                . view('templates/bas');
        }
    }
    public function afficher_galerie_candidature($id)
    {
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));
        $data['titre'] = "Galerie des candidatures";
        $data['candidature'] = $this->model->get_candidat_concours_categorie($id);
        if ($session->has('user')) {
            if ($data['compte']->jur_id != null || $data['compte']->adm_id != null) {
                        return view('templates/haut_admin', $data)
                            . view('compte/compte_candidature_galerie')
                            . view('templates/bas_admin');
            } 
        }
        return view('templates/haut', ['titre' => 'Se connecter'])
        . view('templates/menu_visiteur')
        . view('connexion/compte_connecter')
        . view('templates/bas');

    }
    public function afficher_concours_candidature($can_id)
    {
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));
        $data['candidat'] = $this->model->get_candidat_w_id($can_id);
        $code_dossier = $data['candidat']->can_dossier;
        $data['candidature'] = $this->model->get_candidat($code_dossier);
        $data['documents'] = $this->model->get_documents_candidat($code_dossier);
        if ($session->has('user') ) {
            if ($data['compte']->jur_id != null || $data['compte']->adm_id != null){
                    return view('templates/haut_admin', $data)
                        . view('compte/compte_candidature_concours')
                        . view('templates/bas_admin');
            }
        }   
        $data['titre'] = "Actualités";
        $data['titre2'] = "Concours";
        $data['actualite'] =  $this->model->get_all_actualite();
        $data['concours'] =  $this->model->get_all_concours();
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('affichage_accueil')
            . view('templates/bas');
    }
    public function afficher_concours_concours($id)
    {
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));
        $data['titre'] = "Concours";
        $data['concours'] = $this->model->get_concours($id);
        if ($session->has('user') ) {
            if ($data['compte']->jur_id != null || $data['compte']->adm_id != null){
                    return view('templates/haut_admin', $data)
                        . view('concours/concours_concours')
                        . view('templates/bas_admin');
            }
        }   
        $data['titre'] = "Actualités";
        $data['titre2'] = "Concours";
        $data['actualite'] =  $this->model->get_all_actualite();
        $data['concours'] =  $this->model->get_all_concours();
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('affichage_accueil')
            . view('templates/bas');
    }
    public function ajouter_concours()
    {
        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        $session = session();
        $data['compte'] = $this->model->get_compte($session->get('user'));

        if ($this->request->getMethod() == "post" && $data['compte']->adm_id != null) {
            if (!$this->validate([
                'login' => 'required|max_length[120]|min_length[5]|is_unique[t_compte_cpt.cpt_login]',
                'prenom' => 'required|max_length[80]|min_length[2]',
                'nom' => 'required|max_length[80]|min_length[2]',
                'mdp' => 'required|max_length[300]|min_length[8]',
                'statut' => 'required',
                'etat' => 'required',
                'mdp2' => 'required|max_length[300]|min_length[8]|matches[mdp]'
            ], [
                // Configuration des messages d’erreurs
                'login' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le login doit contenir au moins 6 caractères.',
                    'max_length' => 'Le login doit contenir au maximum 120 caractères.',
                    'is_unique' => 'Le compte ne peut pas être créé !'
                ],
                'prenom' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le prénom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le prénom doit contenir au maximum 80 caractères.'
                ],
                'nom' => [
                    'required' => 'Champs de saisie vides !.',
                    'min_length' => 'Le nom doit contenir au moins 2 caractères.',
                    'max_length' => 'Le nom doit contenir au maximum 80 caractères.'
                ],
                'mdp' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.'
                ],
                'statut' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le statut doit contenir 1 caractère.',
                    'max_length' => 'Le statut doit contenir 1 caractère.'
                ],
                'mdp2' => [
                    'required' => 'Champs de saisie vides !',
                    'min_length' => 'Le mot de passe doit contenir au moins 8 caractères.',
                    'max_length' => 'Le mot de passe doit contenir au maximum 300 caractères.',
                    'matches' => 'les 2 mots de passe saisis sont différents !!'
                ]
            ])) {
                // La validation du formulaire a échoué, retour au formulaire !
                return view('templates/haut_admin', $data)
                    . view('compte/compte_ajouter_compte', ['titre' => 'Ajouter un compte'])
                    . view('templates/bas_admin');
            }

            // La validation du formulaire a réussi, traitement du formulaire

            $recuperation = $this->validator->getValidated();
            if ($recuperation['statut'] == "administrateur") {
                $this->model->set_compte_profil_admin($recuperation);
            }
            if ($recuperation['statut'] == "jury") {
                $this->model->set_compte_profil_jury($recuperation);
            }

            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                $data['profil'] = $this->model->get_compte($recuperation['login']);
                $data['nb_comptes'] =  $this->model->get_nb_comptes();
                $data['compte'] = $this->model->get_compte($session->get('user'));
                $data['logins'] = $this->model->get_all_compte();
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_comptes', ['titre' => 'Cooncours créé'])
                    . view('templates/bas_admin');
            } else {
                return view('templates/haut_admin', $data)
                    . view('connexion/compte_profil')
                    . view('templates/bas_admin');
            }
        }
        // L’utilisateur veut afficher le formulaire pour créer un concours
        if ($session->has('user')) {
            if ($data['compte']->cpt_etat == 'A' && $data['compte']->adm_id != null) {
                return view('templates/haut_admin', $data)
                    . view('compte/compte_ajouter_concours', ['titre' => 'Ajouter un concours'])
                    . view('templates/bas_admin');
            } else {
                $data['titre'] = "Actvvvvvvvvvualités";
                $data['titre2'] = "Concours";
                $data['actualite'] =  $this->model->get_all_actualite();
                $data['concours'] =  $this->model->get_all_concours();
                return view('templates/haut', $data)
                    . view('templates/menu_visiteur')
                    . view('affichage_accueil')
                    . view('templates/bas');
            }
        }
    }
}
