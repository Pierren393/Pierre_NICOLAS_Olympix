<style>
    .card {
        border: 1px solid #dd2476;
        color: rgba(250, 250, 250, 0.8);
        margin-bottom: 2rem;
    }
</style>
<!-- banner section start -->
<div class="banner_section layout_padding">
    <div id="carouselExampleSlidesOnly" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <div class="container">
                    <h1 class="banner_taital">Olympix</h1>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- banner section end -->
</div>
<!-- header section end -->
<!-- services section start -->


<div class="container mx-auto mt-4">
    <div class="row">
        <?php
        if (!empty($candidature) && is_array($candidature)) {
            echo "<h1 style='color: black' class='banner_taital'>Candidat pré-sélectionnés</h1>";

            foreach ($candidature as $can) {
        ?>
                <div class="col-md-4 mb-4">
                    <div class="card" style="width: 18rem;">
                            <a href="<?= base_url('index.php/concours/afficher_galerie_candidature/candidature/' . $can['can_id']) ?>" >
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