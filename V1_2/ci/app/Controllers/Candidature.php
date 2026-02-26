<?php

namespace App\Controllers;

use App\Models\Db_model;
use CodeIgniter\Exceptions\PageNotFoundException;

class Candidature extends BaseController
{
    protected $model;
    public function __construct()
    {
        helper('form');
        $this->model = model(Db_model::class);
    }
    public function afficher($code_dossier)
    {
        $data['titre'] = 'Votre candidature';
        $data['candidature'] = $this->model->get_candidat($code_dossier);
        $data['documents'] = $this->model->get_documents_candidat($code_dossier);
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('candidature/affichage_candidature')
            . view('templates/bas');
    }
    public function visualiser()
    {
        // L’utilisateur a validé le formulaire en cliquant sur le bouton
        if ($this->request->getMethod() == "post") {
            if (! $this->validate([
                'candidature' => 'required|max_length[8]|min_length[8]',
                'dossier' => 'required|max_length[20]|min_length[20]',
            ], [
                // Configuration des messages d’erreurs
                'candidature' => [
                    'required' => 'Veuillez remplir le formulaire !',
                    'min_length' => 'Le code de la candidature saisi est trop court !',
                    'max_length' => 'Le code de la candidature saisi est trop long !',
                ],
                'dossier' => [
                    'required' => 'Veuillez remplir le formulaire !',
                    'min_length' => 'Le code du dossier saisi est trop court !',
                    'max_length' => 'Le code du dossier saisi est trop long !',

                ]
            ])) {
                // La validation du formulaire a échoué, retour au formulaire !
                return view('templates/haut', ['titre' => 'Code(s) erroné(s), aucune candidature (/inscription) trouvée !'])
                    . view('templates/menu_visiteur')
                    . view('candidature/candidature_visualiser')
                    . view('templates/bas');
            }
            // La validation du formulaire a réussi, traitement du formulaire

            $candidature = $this->request->getVar('candidature');
            $dossier = $this->request->getVar('dossier');

            $data['candidature'] = $this->model->get_candidat_w_code($dossier, $candidature);

            //Appel de la fonction créée dans le précédent tutoriel :
            //$data['le_total'] =  $this->model->get_nb_comptes();

            if ($data['candidature'] != null) {
                return view('templates/haut', $data)
                    . view('templates/menu_visiteur')
                    . view('candidature/affichage_candidature')
                    . view('templates/bas');
            } else {
                return view('templates/haut', ['titre' => 'Visualiser votre récapitulatif'])
                    . view('templates/menu_visiteur')
                    . view('candidature/candidature_visualiser')
                    . view('templates/bas');
            }
        }
        // L’utilisateur veut afficher le formulaire pour afficher sa candidature
        return view('templates/haut', ['titre' => 'Visualiser votre récapitulatif'])
            . view('templates/menu_visiteur')
            . view('candidature/candidature_visualiser')
            . view('templates/bas');
    }
    public function supprimer($code_dossier, $code_can)
    {

        $this->model->del_candidat($code_dossier, $code_can);
        return view('templates/haut', ['titre' => 'Candidature supprimé !'])
            . view('templates/menu_visiteur')
            . view('candidature/candidature_visualiser')
            . view('templates/bas');
    }
    public function afficher_galerie_candidature($id)
    {
        $data['titre'] = "Galerie des candidatures";
        $data['candidature'] = $this->model->get_candidat_concours_categorie($id);
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('candidature/candidature_galerie')
            . view('templates/bas');
    }
}
