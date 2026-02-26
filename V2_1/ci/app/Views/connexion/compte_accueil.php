<h2>Espace d'administration</h2>
<br />
<h2>Session ouverte ! 
    <?php
    $session = session();
    echo "<br>";
    echo "<br>Bienvenue ";
    echo $session->get('user');
    if ($compte->adm_id != NULL) {
        echo "<br>"; 
        echo "Vous êtes organisateur";
    } else if ($compte->jur_id != NULL) {
        echo "<br>";
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