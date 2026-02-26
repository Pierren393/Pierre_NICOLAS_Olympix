<h2><?php echo $titre; ?></h2>

<!-- banner section start -->
<div class="banner_section layout_padding">
    <div id="carouselExampleSlidesOnly" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <div class="container">
                    <h1 class="banner_taital">Adventure</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
            <div class="carousel-item">
                <div class="container">
                    <h1 class="banner_taital">Adventure</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
            <div class="carousel-item">
                <div class="container">
                    <h1 class="banner_taital">Adventure</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- banner section end -->
</div>
<!-- header section end -->
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital">Liste des comptes</h1>
        <?php
        if (isset($nb_comptes)) {
            echo ("Nombre de comptes: $nb_comptes->nb_comptes");
            echo "<br />";
        } else {
            echo ("Pas de comptes !");
        }

        if (! empty($logins) && is_array($logins)) {
            foreach ($logins as $pseudos) {
                echo "<br />";
                echo " -- ";
                echo $pseudos["cpt_login"];
                echo " -- ";
                echo "<br />";
            }
        } else {
            echo ("<h3>Aucun compte pour le moment</h3>");
        }

        ?>

    </div>
</div>
<!-- services section end -->