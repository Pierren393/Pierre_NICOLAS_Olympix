<h2>Espace d'administration</h2>
<br />
<h2>Session ouverte ! Bienvenue compte accueil
    <?php
    $session = session();
    echo $session->get('user');
    echo "<br>";
    if ($compte->adm_id != NULL) {
        echo "Vous êtes organisateur";
    } else if ($compte->jur_id != NULL) {
        echo "Vous êtes membre du jury";
    } else {
        $session = session();
        $session->destroy();
        return view('templates/haut')
            . view('templates/menu_visiteur')
            . view('connexion/connecter', $data)
            . view('templates/bas');
    }

    ?>

</h2>