<style>
    .card {
        border: 1px solid #dd2476;
        color: rgba(250, 250, 250, 0.8);
        margin-bottom: 2rem;
    }
    .avatar {
        width:50%;
    }
   

</style>
<div class="container mx-auto mt-4">
   
        <?php
        if (!empty($candidature) && is_array($candidature)) {
            echo "<h1 style='color: black' class='banner_taital'>Candidat pré-sélectionnés</h1>";
            echo"<br>";
            foreach ($candidature as $can) {
        ?>
         <div class="row">
                <div class="col-md-4 mb-4">
                    <div class="card" style="width: 18rem;">
                            <a href="<?= base_url('index.php/compte/afficher_concours/afficher_galerie_candidature/candidature/' . $can['can_id']) ?>" >
                                <img src="<?= base_url() . 'images/avatar'; ?>"
                                    class="avatar">
                                <div class="card-body">
                                    <h5 class="card-title">
                                        <?= $can["can_prenom"] . " " . $can["can_nom"] ?>
                                    </h5>
                                    <h6 class="card-subtitle mb-2 text-muted">Catégorie: <?= $can["cat_nom"] ?></h6>

                                </div>
                            </a>
                    </div>
                </div>
        <?php
            }
        } else {
            echo "<br>";
            echo "<h2>Aucun candiat</h2>";
        }
        ?>
    </div>
</div>



<!-- services section end -->