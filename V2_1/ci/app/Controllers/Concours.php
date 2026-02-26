<?php

namespace App\Controllers;

use App\Models\Db_model;
use CodeIgniter\Exceptions\PageNotFoundException;

class Concours extends BaseController
{
    public function __construct()
    {
        //...
    }
    public function afficher()
    {
        $model = model(Db_model::class);
        $data['titre'] = "Concours";
        $data['concours'] = $model->get_all_concours();
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('affichage_concours')
            . view('templates/bas');
    }
    public function afficher_concours($id)
    {
        $model = model(Db_model::class);
        $data['titre'] = "Concours";
        $data['concours'] = $model->get_concours($id);
        return view('templates/haut', $data)
            . view('templates/menu_visiteur')
            . view('concours/concours_concours')
            . view('templates/bas');
    }
}
