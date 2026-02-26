<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital"><?= $titre ?></h1>
        <?php

        if (isset($profil)) {
            if ($profil->adm_id != null) {
                echo "Pseudo : " . $profil->cpt_login . " <br>";
                echo "Prenom : " . $profil->cpt_prenom . " <br>";
                echo "Nom : " . $profil->cpt_nom . " <br>";
            } else if ($profil->jur_id != null) {
                echo "Pseudo : " . $profil->cpt_login . " <br>";
                echo "Prenom : " . $profil->cpt_prenom . " <br>";
                echo "Nom : " . $profil->cpt_nom . " <br>";
                echo "Informations restantes à remplir par l'utilisateur";
                echo "Discipline : " . $profil->jur_domaine_expertise . " <br>";
                echo "Biographie : " . $profil->jur_biographie . " <br>";
                echo 'URL du site Web : <a href="' . $profil->jur_url . '">' . $profil->jur_url . '</a><br>';
            }
        }
        echo "<br>";
        if (isset($nb_comptes)) {
            echo ("Nombre de comptes: $nb_comptes->nb_comptes");
            echo "<br />";
        } else {
            echo ("Pas de comptes !");
        }
        ?>
        <table class="table">
            <thead>
                <tr>
                    <th scope="col">Login</th>
                    <th scope="col">Nom</th>
                    <th scope="col">Prenom</th>
                    <th scope="col">Etat (activé/désactivé)</th>
                    <th scope="col">Statut</th>
                    <th scope="" style="color: white;">zerzez</th>

                </tr>
            </thead>
            <tbody>
                <?php
                if (! empty($logins) && is_array($logins)) {
                    foreach ($logins as $pseudos) {
                        echo "<tr>";
                        echo "<td>" . $pseudos["cpt_login"] . "</td>";
                        echo "<td>" . $pseudos["cpt_nom"] . "</td>";
                        echo "<td>" . $pseudos["cpt_prenom"] . "</td>";
                        echo "<td>
                                <select name='etat' class='form-control' style='width: auto;'>
                                    <option value='A'" . ($pseudos["cpt_etat"] == 'A' ? " selected" : "") . ">Activé</option>
                                    <option value='D'" . ($pseudos["cpt_etat"] == 'D' ? " selected" : "") . ">Désactivé</option>
                                </select>
                            </td>";
                        if ($pseudos["adm_id"] != null) {
                            echo "<td>Organisateur</td>";
                        } else if ($pseudos["jur_id"] != null) {
                            echo "<td>Jury</td>";
                        }
                        if ($pseudos["cpt_login"] != "organisateur@Olympix.com")
                            echo "<td><img src='" . base_url() . "images/poubelle' height='50px'></td>";
                    }
                } else {
                    echo "<h3>Aucun comptes</h3>";
                }
                ?>
            </tbody>
        </table>
        <br>
        <div style="display: flex; justify-content: left; align-items: center; margin-left:10%;">
            <button type="button" class="btn btn-primary" style="width: auto;" onclick="window.location.href='<?= base_url('index.php/compte/ajouter_profil'); ?>';">
                Ajouter un compte
            </button>
        </div>

    </div>
    <!-- services section end -->