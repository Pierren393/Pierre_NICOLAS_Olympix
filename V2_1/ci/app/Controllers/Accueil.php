<?php

namespace App\Controllers;

use App\Models\Db_model;
use CodeIgniter\Exceptions\PageNotFoundException;

class Accueil extends BaseController
{
    public function afficher()
    {
        $model = model(Db_model::class);
        $data['titre'] = "Actualités";
        $data['titre2'] = "Concours";
        $data['actualite'] = $model->get_all_actualite();
        $data['concours'] = $model->get_all_concours();
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('affichage_accueil')
            . view('templates/bas');
    }
}
