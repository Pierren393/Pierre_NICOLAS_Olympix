<h1></h1><br />
<!-- banner section start -->

<!-- banner section end -->
</div>
<!-- header section end -->
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="banner_taital" style="color: black;">Votre candidature</h1>
        <?php
        if (isset($candidature)) {
            echo "<h1 class='services_taital'>Bonjour " . $candidature->can_prenom . ' ' . $candidature->can_nom . "</h1>";
            if ($candidature->can_retenue == 'I') {
                echo "Vous êtes inscrit pour le concours: $candidature->con_nom<br>";
            }
            if ($candidature->can_retenue == "R") {
                echo "Vous êtes sélectionné pour le concours: $candidature->con_nom<br>";
            } else {
                echo "Candidature rejeté pour le concours: $candidature->con_nom<br>";
            }

            echo "Catégorie du concours: " . $candidature->cat_nom . " <br>";
            echo "Prenom: " . $candidature->can_prenom . " <br>";
            echo "nom: " . $candidature->can_nom . " <br>";
            echo "code du dossier: " . $candidature->can_dossier . " <br>";
            echo "code de la candidature: " . $candidature->can_code . " <br>";
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
        <br>
        <a href="<?= base_url('index.php/candidature/supprimer/' . $candidature->can_dossier . '/' . $candidature->can_code) ?>"
            onclick="return confirmerSuppression(event)"
            class="btn btn-danger">
            Supprimer ma candidature
        </a>
        <script>
            function confirmerSuppression(event) {
                if (confirm('Êtes-vous sûr de vouloir supprimer cette candidature ?')) {
                    // Afficher une alerte après suppression
                    setTimeout(() => {
                        alert('Candidature supprimée');
                    }, 200); // Retard pour attendre la redirection
                    return true; // Continue vers la suppression
                } else {
                    event.preventDefault(); // Annuler la redirection si l'utilisateur annule
                    return false;
                }
            }
        </script>
    </div>
</div>
<!-- services section end -->