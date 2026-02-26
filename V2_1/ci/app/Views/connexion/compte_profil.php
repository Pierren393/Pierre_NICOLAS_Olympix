<h2>Données du compte</h2>
<br>

<?php
if (!empty($titre)) {
    echo "<h3>$titre</h3><br>";
}

if (isset($profil)) {
    if ($profil->adm_id != null) {
        echo "Pseudo : " . $profil->cpt_login . " <br>";
        echo "Prenom : " . $profil->cpt_prenom . " <br>";
        echo "Nom : " . $profil->cpt_nom . " <br>";
    } else if ($profil->jur_id != null) {
        echo "Pseudo : " . $profil->cpt_login . " <br>";
        echo "Prenom : " . $profil->cpt_prenom . " <br>";
        echo "Nom : " . $profil->cpt_nom . " <br>";
        echo "Discipline : " . $profil->jur_domaine_expertise . " <br>";
        echo "Biographie : " . $profil->jur_biographie . " <br>";
        echo 'URL du site Web : <a href="' . $profil->jur_url . '">' . $profil->jur_url . '</a><br>';
    }
}

?>
<br>
<div style="display: flex; justify-content: left; align-items: center; margin-left:10%;">
    <button type="button" class="btn btn-primary" style="width: auto;" onclick="window.location.href='<?= base_url('index.php/compte/changer_mdp'); ?>';">
        Changer de mot de passe
    </button>
</div>