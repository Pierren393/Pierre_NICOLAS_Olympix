<h1><?php echo $titre; ?></h1><br />
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
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital">Actualité <?= $news->act_id ?></h1>
        <?php
        if (isset($news)) {
            echo $news->act_id;
            echo (" -- ");
            echo $news->act_titre;
        } else {
            echo ("Pas d'actualité !");
        }
        ?>

    </div>
</div>
<!-- services section end -->