<h1></h1><br />
<!-- banner section start -->

<!-- banner section end -->
</div>
<!-- header section end -->
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h2 class="banner_taital" style="color: black;">Candidature de <?= $candidature->can_prenom . ' ' . $candidature->can_nom ?></h2>
        <?php
        if (isset($candidature)) {
            echo "Je suis très motivé par ce concours !<br>";
            if ($candidature->can_retenue == 'I') {
                echo "Inscrit pour le concours: $candidature->con_nom<br>";
            }
            if ($candidature->can_retenue == "R" || $candidature->can_retenue == "F") {
                echo "Sélectionné pour le concours: $candidature->con_nom<br>";
            } else {
                echo "Candidature rejeté pour le concours: $candidature->con_nom<br>";
            }

            echo "Catégorie du concours: " . $candidature->cat_nom . " <br>";
            echo "Prenom: " . $candidature->can_prenom . " <br>";
            echo "nom: " . $candidature->can_nom . " <br>";
            echo "mail: " . $candidature->can_mail . " <br>";
            echo "Date de la candidature: " . $candidature->can_date . " <br>";
            if (! empty($documents) && is_array($documents)) {
                echo "<b>Documents: </b>";
                foreach ($documents as $doc) {
                    echo "<li>nom: " . $doc['res_nom'] . " </li>";
                    echo "<img src='" . base_url() . "images/" . $doc['res_chemin'] . "' width='200px'></li>";
                }
            } else {
                echo "Pas de documents";
            }
        } else {
            echo "Aucune candidature<br>";
        }

        ?>
    </div>
</div>
<!-- services section end -->